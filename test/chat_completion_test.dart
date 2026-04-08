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

  group("Chat Completion - Full Coverage", () {
    test("Simple text response with usage", () async {
      mock.setResponse({
        "id": "gen-1",
        "model": "meta-llama/llama-3",
        "choices": [
          {
            "message": {"role": "assistant", "content": "Hello!"},
            "finish_reason": "stop",
          },
        ],
        "usage": {
          "prompt_tokens": 5,
          "completion_tokens": 2,
          "total_tokens": 7,
        },
      });

      final res = await client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: "m",
          messages: [ChatMessage.user("Hi")],
        ),
      );

      final data = (res as Success).value;
      expect(data.content, "Hello!");
      expect(data.usage?.totalTokens, 7);
      expect(data.model, "meta-llama/llama-3");
    });

    test("Tool Calls (Function Calling) mapping", () async {
      mock.setResponse({
        "id": "gen-2",
        "model": "m",
        "choices": [
          {
            "message": {
              "role": "assistant",
              "content": "",
              "tool_calls": [
                {
                  "id": "call_1",
                  "type": "function",
                  "function": {
                    "name": "get_weather",
                    "arguments": "{\"city\": \"London\"}",
                  },
                },
              ],
            },
          },
        ],
      });

      final res = await client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: "m",
          messages: [ChatMessage.user("Weather?")],
        ),
      );

      final msg = (res as Success).value.choices.first.message;
      expect(msg.toolCalls?.first.functionName, "get_weather");
      expect(msg.toolCalls?.first.id, "call_1");
    });

    test("Reasoning field (for o1/DeepSeek models)", () async {
      mock.setResponse({
        "id": "gen-3",
        "model": "m",
        "choices": [
          {
            "message": {
              "role": "assistant",
              "content": "Result",
              "reasoning": "Thinking process...",
            },
          },
        ],
      });

      final res = await client.createChatCompletion(
        request: CreateChatCompletionRequest(model: "m", messages: []),
      );

      expect((res as Success).value.reasoning, "Thinking process...");
    });

    test("Response Format: JSON Schema", () async {
      final req = CreateChatCompletionRequest(
        model: "m",
        messages: [],
        responseFormat: ResponseFormat.jsonSchema(
          name: "test_schema",
          schema: {
            "type": "object",
            "properties": {
              "name": {"type": "string"},
            },
          },
        ),
      );

      final json = req.toJson();
      expect(json["response_format"]["type"], "json_schema");
      expect(json["response_format"]["json_schema"]["name"], "test_schema");
    });

    test("Multimodal Input (Images)", () async {
      final req = CreateChatCompletionRequest(
        model: "m",
        messages: [
          ChatMessage.user([
            ChatContentPart.text("What is this?"),
            ChatContentPart.imageUrl(
              "https://example.com/i.png",
              detail: "high",
            ),
          ]),
        ],
      );

      final json = req.toJson();
      final messages = json["messages"] as List;
      final firstMessage = messages[0] as Map<String, dynamic>;
      final content = firstMessage["content"] as List;

      expect(content[0]["type"], "text");
      expect(content[0]["text"], "What is this?");
      expect(content[1]["type"], "image_url");
      expect(content[1]["image_url"]["url"], "https://example.com/i.png");
      expect(content[1]["image_url"]["detail"], "high");
    });
  });
}
