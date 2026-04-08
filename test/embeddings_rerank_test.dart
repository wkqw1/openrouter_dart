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

  group("Embeddings", () {
    test("Float format success", () async {
      mock.setResponse({
        "model": "text-emb",
        "data": [
          {
            "index": 0,
            "embedding": [0.1, 0.2],
          },
        ],
      });

      final res = await client.createEmbedding(
        request: CreateEmbeddingRequest(
          model: "m",
          input: EmbeddingInput.text("hi"),
        ),
      );

      expect((res as Success).value.embedding, [0.1, 0.2]);
    });

    test("Base64 format decoding", () async {
      mock.setResponse({
        "model": "text-emb",
        "data": [
          {"index": 0, "embedding": "AAAAAABAREALRA=="},
        ],
      });

      final res = await client.createEmbedding(
        request: CreateEmbeddingRequest(
          model: "m",
          input: EmbeddingInput.text("hi"),
        ),
      );
      expect(res.isSuccess, true);
    });
  });

  group("Rerank", () {
    test("Basic rerank mapping", () async {
      mock.setResponse({
        "model": "m",
        "results": [
          {
            "index": 2,
            "relevance_score": 0.95,
            "document": {"text": "doc 3"},
          },
        ],
      });

      final res = await client.createRerank(
        request: CreateRerankRequest(
          model: "m",
          query: "q",
          documents: ["a", "b", "c"],
        ),
      );

      final result = (res as Success).value.results.first;
      expect(result.index, 2);
      expect(result.text, "doc 3");
    });
  });
}
