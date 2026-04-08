import "tool_models.dart";

class CompletionUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  CompletionUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory CompletionUsage.fromJson(Map<String, dynamic> json) =>
      CompletionUsage(
        promptTokens: (json["prompt_tokens"] as num?)?.toInt() ?? 0,
        completionTokens: (json["completion_tokens"] as num?)?.toInt() ?? 0,
        totalTokens: (json["total_tokens"] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "prompt_tokens": promptTokens,
    "completion_tokens": completionTokens,
    "total_tokens": totalTokens,
  };

  @override
  String toString() =>
      "CompletionUsage(prompt: $promptTokens, completion: $completionTokens, total: $totalTokens";
}

class CompletionMessage {
  final String role;
  final String content;

  final String? reasoning;
  final List<ChatToolCall>? toolCalls;

  CompletionMessage({
    required this.role,
    required this.content,
    this.reasoning,
    this.toolCalls,
  });

  factory CompletionMessage.fromJson(Map<String, dynamic> json) =>
      CompletionMessage(
        role: json["role"] as String? ?? "assistant",
        content: json["content"] as String? ?? "",
        reasoning: json["reasoning"] as String?,
        toolCalls: json["tool_calls"] != null
            ? (json["tool_calls"] as List)
                  .map((e) => ChatToolCall.fromJson(e))
                  .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
    "role": role,
    "content": content,
    if (reasoning != null) "reasoning": reasoning,
    if (toolCalls != null) "toolCalls": toolCalls,
  };

  @override
  String toString() =>
      "CompletionMessage(role: $role, content: $content, reasoning: $reasoning, toolCalls: $toolCalls)";
}

class CompletionChoice {
  final int index;
  final CompletionMessage message;
  final String? finishReason;

  CompletionChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory CompletionChoice.fromJson(Map<String, dynamic> json) =>
      CompletionChoice(
        index: (json["index"] as num?)?.toInt() ?? 0,
        message: CompletionMessage.fromJson(
          json["message"] as Map<String, dynamic>,
        ),
        finishReason: json["finish_reason"] as String?,
      );

  Map<String, dynamic> toJson() => {
    "index": index,
    "message": message.toJson(),
    if (finishReason != null) "finish_reason": finishReason,
  };

  @override
  String toString() =>
      "CompletionChoice(index: $index, finishReason: $finishReason, message: $message)";
}

class ChatCompletionResponse {
  final String id;
  final String? provider;
  final String model;
  final List<CompletionChoice> choices;
  final CompletionUsage? usage;
  final Map<String, dynamic> raw;

  ChatCompletionResponse({
    required this.id,
    this.provider,
    required this.model,
    required this.choices,
    this.usage,
    required this.raw,
  });

  String get content => choices.first.message.content;

  String? get reasoning => choices.first.message.reasoning;

  factory ChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    final rawChoices = json["choices"] as List<dynamic>;
    return ChatCompletionResponse(
      id: json["id"] as String,
      provider: json["provider"] as String?,
      model: json["model"] as String,
      choices: rawChoices
          .map((e) => CompletionChoice.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      usage: json["usage"] != null
          ? CompletionUsage.fromJson(json["usage"] as Map<String, dynamic>)
          : null,
      raw: json,
    );
  }

  @override
  String toString() =>
      "ChatCompletionResponse(id: $id, model: $model, provider: $provider, choices: ${choices.length}, usage: $usage)";
}
