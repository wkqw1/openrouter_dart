import "package:test/test.dart";
import "package:dio/dio.dart";
import "package:openrouter_dart/openrouter.dart";
import "test_utils.dart";

void main() {
  late OpenRouterClient client;
  late MockAdapter mock;

  setUp(() {
    mock = MockAdapter();
    final dio = Dio()..httpClientAdapter = mock;
    client = OpenRouterClient(
      config: OpenRouterClientConfig(apiKey: "key"),
      dioClient: dio,
    );
  });

  group("Exception Handling", () {
    test("404 Not Found -> OpenRouterApiException", () async {
      mock.setResponse({
        "error": {"message": "Model not found"},
      }, status: 404);

      final res = await client.getModels();

      expect(res.isFailure, true);
      final err = (res as Failure).error as OpenRouterApiException;
      expect(err.statusCode, 404);
      expect(err.message, contains("Model not found"));
    });

    test("Invalid JSON response -> OpenRouterApiException", () async {
      mock.setResponse(["not", "an", "object"]);

      final res = await client.getCredits();
      expect(res.isFailure, true);

      final error = (res as Failure).error as OpenRouterException;
      expect(error.message, contains("Unexpected response format"));
    });
  });
}
