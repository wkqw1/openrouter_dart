import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:openrouter_dart/openrouter.dart';
import 'test_utils.dart';

void main() {
  late OpenRouterClient client;
  late MockAdapter mock;

  setUp(() {
    mock = MockAdapter();
    final dio = Dio()..httpClientAdapter = mock;
    client = OpenRouterClient(
      config: OpenRouterClientConfig(apiKey: 'key'),
      dioClient: dio,
    );
  });

  group('Streaming Completion', () {
    test('Handles multiple chunks and [DONE]', () async {
      mock.setStreamResponse([
        'data: {"choices": [{"delta": {"content": "Deep"}}]}\n\n',
        'data: {"choices": [{"delta": {"content": "Seek"}}]}\n\n',
        'data: [DONE]\n\n',
      ]);

      final stream = client.streamChatCompletion(
        request: CreateChatCompletionRequest(model: 'm', messages: []),
      );

      final results = await stream.toList();
      expect(results.length, 2);
      expect(results[0].content, "Deep");
      expect(results[1].content, "Seek");
    });

    test('Handles Tool Calls in stream', () async {
      mock.setStreamResponse([
        'data: {"choices": [{"delta": {"tool_calls": [{"id": "1", "function": {"name": "test", "arguments": ""}}]}}]}\n\n',
        'data: [DONE]\n\n',
      ]);

      final stream = client.streamChatCompletion(
        request: CreateChatCompletionRequest(model: 'm', messages: []),
      );

      final first = await stream.first;
      expect(first.toolCalls?.first.functionName, "test");
    });

    test('Ignores empty lines or comments', () async {
      mock.setStreamResponse([
        ': ping\n\n',
        'data: {"choices": [{"delta": {"content": "A"}}]}\n\n',
        '\n\n',
        'data: [DONE]\n\n',
      ]);

      final stream = client.streamChatCompletion(
        request: CreateChatCompletionRequest(model: 'm', messages: []),
      );

      final results = await stream.toList();
      expect(results.length, 1);
      expect(results[0].content, "A");
    });
  });
}
