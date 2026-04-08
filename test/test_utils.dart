import "dart:convert";
import "dart:typed_data";
import "package:dio/dio.dart";

class MockAdapter implements HttpClientAdapter {
  late Stream<Uint8List> responseStream;
  int statusCode = 200;

  void setResponse(dynamic json, {int status = 200}) {
    final content = utf8.encode(jsonEncode(json));
    responseStream = Stream.value(Uint8List.fromList(content));
    statusCode = status;
  }

  void setStreamResponse(List<String> chunks) {
    responseStream = Stream.fromIterable(
      chunks.map((c) => Uint8List.fromList(utf8.encode(c))),
    );
    statusCode = 200;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody(
      responseStream,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
