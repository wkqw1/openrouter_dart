import "dart:io" as io;
import "dart:convert";

import "package:dio/dio.dart" as dio;
import "package:dio/io.dart" as dio_io;

import "exceptions.dart";
import "result.dart";

import "models/proxy_settings.dart";
import "models/request_models.dart";
import "models/response_models.dart";
import "models/embedding_models.dart";
import "models/credit_models.dart";
import "models/endpoint_models.dart";
import "models/rerank_models.dart";
import "models/model_info.dart";
import "models/tool_models.dart";

final class OpenRouterClientConfig {
  final String apiKey;
  final ProxySettings? proxy;

  final Duration connectTimeout;
  final Duration receiveTimeout;

  final bool enableLogging;

  final String? httpReferer;
  final String? xTitle;

  const OpenRouterClientConfig({
    required this.apiKey,
    this.proxy,
    this.connectTimeout = const Duration(seconds: 60),
    this.receiveTimeout = const Duration(seconds: 60),
    this.httpReferer,
    this.xTitle,
    this.enableLogging = false,
  });
}

final class OpenRouterClient {
  final dio.Dio _http;
  final OpenRouterClientConfig _config;

  OpenRouterClient({required OpenRouterClientConfig config, dio.Dio? dioClient})
    : _config = config,
      _http = dioClient ?? _buildDioClient(config);

  Future<OpenRouterResult<ChatCompletionResponse, OpenRouterException>>
  createChatCompletion({
    required CreateChatCompletionRequest request,
    Duration? receiveTimeout,
  }) async {
    try {
      final dio.Response<dynamic> response = await _http.post<dynamic>(
        "/chat/completions",
        data: request.toJson(),
        options: receiveTimeout != null
            ? dio.Options(receiveTimeout: receiveTimeout)
            : null,
      );

      return _parseResponse(response);
    } on dio.DioException catch (e) {
      return Failure(_mapDioException(e));
    } catch (e, st) {
      return Failure(
        OpenRouterUnknownException(
          message: e.toString(),
          error: e,
          stackTrace: st,
        ),
      );
    }
  }

  Stream<ChatStreamDelta> streamChatCompletion({
    required CreateChatCompletionRequest request,
  }) async* {
    final body = request.toJson()..["stream"] = true;

    final response = await _http.post<dio.ResponseBody>(
      "/chat/completions",
      data: body,
      options: dio.Options(responseType: dio.ResponseType.stream),
    );

    final stream = response.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in stream) {
      if (line.isEmpty || !line.startsWith("data: ")) continue;
      if (line == "data: [DONE]") break;

      try {
        final json = jsonDecode(line.substring(6));
        final choice = (json["choices"] as List).first;
        final delta = choice["delta"] as Map<String, dynamic>;

        yield ChatStreamDelta(
          content: delta["content"] as String?,
          toolCalls: delta["tool_calls"] != null
              ? (delta["tool_calls"] as List)
                    .map((e) => ChatToolCall.fromJson(e))
                    .toList()
              : null,
        );
      } catch (e) {
        if (_config.enableLogging) {
          print("[OpenRouter] Stream error: $e");
        }
        rethrow;
      }
    }
  }

  Future<OpenRouterResult<EmbeddingResponse, OpenRouterException>>
  createEmbedding({
    required CreateEmbeddingRequest request,
    Duration? receiveTimeout,
  }) async {
    try {
      final dio.Response<dynamic> response = await _http.post<dynamic>(
        "/embeddings",
        data: request.toJson(),
        options: receiveTimeout != null
            ? dio.Options(receiveTimeout: receiveTimeout)
            : null,
      );

      return _parseEmbeddingResponse(response);
    } on dio.DioException catch (e) {
      return Failure(_mapDioException(e));
    } catch (e, st) {
      return Failure(
        OpenRouterUnknownException(
          message: e.toString(),
          error: e,
          stackTrace: st,
        ),
      );
    }
  }

  Future<OpenRouterResult<RerankResponse, OpenRouterException>> createRerank({
    required CreateRerankRequest request,
  }) async {
    try {
      final response = await _http.post<dynamic>(
        "/rerank",
        data: request.toJson(),
      );
      return Success(RerankResponse.fromJson(response.data));
    } on dio.DioException catch (e) {
      return Failure(_mapDioException(e));
    } catch (e, st) {
      return Failure(
        OpenRouterUnknownException(
          message: e.toString(),
          error: e,
          stackTrace: st,
        ),
      );
    }
  }

  Future<OpenRouterResult<List<OpenRouterModelInfo>, OpenRouterException>>
  getModels() async {
    try {
      final response = await _http.get<dynamic>("/models");
      final data = response.data["data"] as List?;
      if (data == null) return Success([]);
      return Success(data.map((m) => OpenRouterModelInfo.fromJson(m)).toList());
    } on dio.DioException catch (e) {
      return Failure(_mapDioException(e));
    } catch (e, st) {
      return Failure(
        OpenRouterUnknownException(
          message: e.toString(),
          error: e,
          stackTrace: st,
        ),
      );
    }
  }

  Future<OpenRouterResult<ModelEndpointsResponse, OpenRouterException>>
  getModelEndpoints({required String author, required String slug}) async {
    try {
      final response = await _http.get<dynamic>(
        "/models/$author/$slug/endpoints",
      );
      return Success(ModelEndpointsResponse.fromJson(response.data));
    } on dio.DioException catch (e) {
      return Failure(_mapDioException(e));
    } catch (e, st) {
      return Failure(
        OpenRouterUnknownException(
          message: e.toString(),
          error: e,
          stackTrace: st,
        ),
      );
    }
  }

  Future<OpenRouterResult<OpenRouterCredits, OpenRouterException>>
  getCredits() async {
    try {
      final dio.Response<dynamic> response = await _http.get<dynamic>(
        "/credits",
      );
      final dynamic data = response.data;

      if (data is! Map<String, dynamic> || !data.containsKey("data")) {
        return Failure(
          OpenRouterApiException(
            message: "Unexpected response format: \"data\" field missing.",
            statusCode: response.statusCode,
            data: data,
          ),
        );
      }

      return Success(OpenRouterCredits.fromJson(data));
    } on dio.DioException catch (e) {
      return Failure(_mapDioException(e));
    } catch (e, st) {
      return Failure(
        OpenRouterUnknownException(
          message: e.toString(),
          error: e,
          stackTrace: st,
        ),
      );
    }
  }

  void dispose() => _http.close();

  OpenRouterResult<ChatCompletionResponse, OpenRouterException> _parseResponse(
    dio.Response<dynamic> response,
  ) {
    final dynamic data = response.data;

    if (data is! Map<String, dynamic>) {
      return Failure(
        OpenRouterApiException(
          message:
              "Unexpected response format: expected a JSON object, got ${data.runtimeType}.",
          statusCode: response.statusCode,
          data: data,
        ),
      );
    }

    if (data.containsKey("error")) {
      final dynamic raw = data["error"];
      final String message = raw is Map
          ? raw["message"] as String? ?? "API returned an error."
          : "API returned an error.";
      return Failure(
        OpenRouterApiException(
          message: message,
          statusCode: response.statusCode,
          data: data,
        ),
      );
    }

    final String? id = data["id"] as String?;
    if (id == null || id.isEmpty) {
      return Failure(
        OpenRouterApiException(
          message: "Invalid response: \"id\" field is missing or empty.",
          statusCode: response.statusCode,
          data: data,
        ),
      );
    }

    final List<dynamic>? choices = data["choices"] as List?;
    if (choices == null || choices.isEmpty) {
      return Failure(
        OpenRouterApiException(
          message: "Invalid response: \"choices\" array is missing or empty.",
          statusCode: response.statusCode,
          data: data,
        ),
      );
    }

    return Success(ChatCompletionResponse.fromJson(data));
  }

  OpenRouterResult<EmbeddingResponse, OpenRouterException>
  _parseEmbeddingResponse(dio.Response<dynamic> response) {
    final dynamic data = response.data;

    if (data is! Map<String, dynamic>) {
      return Failure(
        OpenRouterApiException(
          message:
              "Unexpected response format: expected a JSON object, got ${data.runtimeType}.",
          statusCode: response.statusCode,
          data: data,
        ),
      );
    }

    if (data.containsKey("error")) {
      final dynamic raw = data["error"];
      final String message = raw is Map
          ? raw["message"] as String? ?? "API returned an error."
          : "API returned an error.";
      return Failure(
        OpenRouterApiException(
          message: message,
          statusCode: response.statusCode,
          data: data,
        ),
      );
    }

    final dynamic embeddingData = data["data"];
    if (embeddingData is! List || embeddingData.isEmpty) {
      return Failure(
        OpenRouterApiException(
          message: "Invalid response: \"data\" array is missing or empty.",
          statusCode: response.statusCode,
          data: data,
        ),
      );
    }

    return Success(EmbeddingResponse.fromJson(data));
  }

  OpenRouterException _mapDioException(dio.DioException e) {
    if (e.type == dio.DioExceptionType.connectionTimeout ||
        e.type == dio.DioExceptionType.receiveTimeout ||
        e.type == dio.DioExceptionType.sendTimeout) {
      return OpenRouterTimeoutException(e.message ?? "Request timed out.");
    }

    if (e.response != null) {
      final dynamic responseData = e.response!.data;
      String message = "HTTP ${e.response!.statusCode} error.";

      if (responseData is Map<String, dynamic>) {
        final dynamic err = responseData["error"];
        if (err is Map) {
          message = err["message"] as String? ?? message;
        }
      }

      return OpenRouterApiException(
        message: message,
        statusCode: e.response!.statusCode,
        data: responseData,
      );
    }

    return OpenRouterNetworkException(
      e.message ?? "An unknown network error occurred.",
    );
  }

  static dio.Dio _buildDioClient(OpenRouterClientConfig config) {
    final Map<String, String> headers = {
      "Authorization": "Bearer ${config.apiKey}",
      "Content-Type": "application/json; charset=utf-8",
      if (config.httpReferer != null) "HTTP-Referer": config.httpReferer!,
      if (config.xTitle != null) "X-Title": config.xTitle!,
    };

    final dio.Dio client = dio.Dio(
      dio.BaseOptions(
        baseUrl: "https://openrouter.ai/api/v1",
        headers: headers,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
      ),
    );

    if (config.enableLogging) {
      client.interceptors.add(
        dio.LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => print("[OpenRouter] $o"),
        ),
      );
    }

    if (config.proxy != null) {
      client.httpClientAdapter = _buildProxyAdapter(config.proxy!);
    }

    return client;
  }

  static dio_io.IOHttpClientAdapter _buildProxyAdapter(ProxySettings proxy) {
    return dio_io.IOHttpClientAdapter(
      createHttpClient: () {
        final httpClient = io.HttpClient();

        httpClient.findProxy = (uri) {
          return "PROXY ${proxy.host}:${proxy.port}";
        };
        httpClient.badCertificateCallback = (cert, host, port) => true;

        if (proxy.requiresAuth) {
          httpClient.authenticateProxy = (host, port, scheme, realm) async {
            httpClient.addProxyCredentials(
              host,
              port,
              realm ?? "",
              io.HttpClientBasicCredentials(proxy.login!, proxy.password!),
            );
            return true;
          };
        }

        return httpClient;
      },
    );
  }
}
