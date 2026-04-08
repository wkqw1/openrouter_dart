# OpenRouter Dart Client

A Dart client wrapper for the [OpenRouter API](https://openrouter.ai/). 

## Features

- ✅ **Complete API Support**: Chat, Streaming, Embeddings, Reranking, Models, and Credits.
- ✅ **Type-Safe**: Uses a `Result` pattern (`Success` or `Failure`) for robust error handling.
- ✅ **Advanced Chat**: Support for Vision (images), Tool Calling (functions), and Reasoning.
- ✅ **Streaming**: Real-time responses using SSE (Server-Sent Events).
- ✅ **Customizable**: Full control over routing, provider settings, and extra body parameters.
- ✅ **Proxy Support**: Easy configuration for restricted environments.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  openrouter_dart: ^1.0.0
```

Or run:
```bash
dart pub add openrouter_dart
```

---

## Quick Start

### Initialize the Client

```dart
import "package:openrouter_dart/openrouter_dart.dart";

final client = OpenRouterClient(
  config: OpenRouterClientConfig(
    apiKey: "YOUR_OPENROUTER_API_KEY",
    httpReferer: "https://your-site.com", // Optional
    xTitle: "Your App Name",              // Optional
    enableLogging: true,                  // Helpful for debugging
  ),
);
```

### Proxy Configuration

```dart
final client = OpenRouterClient(
  config: OpenRouterClientConfig(
    apiKey: "KEY",
    proxy: ProxySettings(
      host: "127.0.0.1",
      port: 8080,
      login: "user",     // Optional
      password: "pass",  // Optional
    ),
  ),
);
```

### Simple Chat Completion

```dart
final result = await client.createChatCompletion(
  request: CreateChatCompletionRequest(
    model: "anthropic/claude-sonnet-4.6",
    messages: [
      ChatMessage.system("You are a helpful assistant."),
      ChatMessage.user("Explain quantum physics in one sentence."),
    ],
  ),
);

result.to(
  onSuccess: (response) => print("AI: ${response.content}"),
  onFailure: (error) => print("Error: ${error.message}"),
);
```

---

## Advanced Usage

### Streaming Responses

```dart
final stream = client.streamChatCompletion(
  request: CreateChatCompletionRequest(
    model: "google/gemini-3-flash-preview",
    messages: [ChatMessage.user("Write a short poem about Dart.")],
  ),
);

await for (final chunk in stream) {
  if (chunk.content != null) {
    stdout.write(chunk.content);
  }
}
```

### Vision (Multimodal)

```dart
final result = await client.createChatCompletion(
  request: CreateChatCompletionRequest(
    model: "google/gemini-2.5-flash-lite",
    messages: [
      ChatMessage.user([
        ChatContentPart.text("What"s in this image?"),
        ChatContentPart.imageUrl("https://example.com/image.jpg"),
      ]),
    ],
  ),
);
```

### Tool Calling (Function Calling)

```dart
final tool = ChatTool(
  name: "get_weather",
  description: "Get the current weather in a location",
  parameters: {
    "type": "object",
    "properties": {
      "location": {"type": "string", "description": "The city name"},
    },
    "required": ["location"],
  },
);

final result = await client.createChatCompletion(
  request: CreateChatCompletionRequest(
    model: "google/gemini-2.5-flash-lite",
    messages: [ChatMessage.user("What is the weather in London?")],
    tools: [tool],
    toolChoice: "auto",
  ),
);
```

### Reranking

```dart
final result = await client.createRerank(
  request: CreateRerankRequest(
    model: "cohere/rerank-4-fast",
    query: "What is Dart?",
    documents: [
      "Dart is a programming language.",
      "The weather is nice today.",
      "Flutter uses Dart to build apps.",
    ],
  ),
);
```

---

## Error Handling

The library uses a sealed `OpenRouterResult` class to force you to handle both success and error cases, making your app more stable.

```dart
final result = await client.getCredits();

if (result.isSuccess) {
  final credits = (result as Success).value;
  print("Remaining balance: ${credits.remainingCredits}");
} else {
  final error = (result as Failure).error;
  if (error is OpenRouterApiException) {
    print("API Error: ${error.message} (Status: ${error.statusCode})");
  } else if (error is OpenRouterNetworkException) {
    print("Network issue: ${error.message}");
  }
}
```