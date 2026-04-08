import "package:test/test.dart";
import "package:dio/dio.dart";
import "package:openrouter_dart/openrouter_dart.dart";
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

  test("getCredits handles response data field", () async {
    mock.setResponse({
      "data": {"total_credits": 100.0, "total_usage": 30.5},
    });

    final res = await client.getCredits();
    final val = (res as Success).value as OpenRouterCredits;
    expect(val.remainingCredits, 69.5);
  });

  test("getModels parses full list", () async {
    mock.setResponse({
      "data": [
        {
          "id": "a",
          "name": "A",
          "description": "",
          "context_length": 1,
          "pricing": {},
        },
        {
          "id": "b",
          "name": "B",
          "description": "",
          "context_length": 2,
          "pricing": {},
        },
      ],
    });

    final res = await client.getModels();
    expect((res as Success).value.length, 2);
  });
}
