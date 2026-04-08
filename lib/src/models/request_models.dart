import "chat_message.dart";
import "tool_models.dart";

class ChatStreamDelta {
  final String? content;
  final List<ChatToolCall>? toolCalls;
  ChatStreamDelta({this.content, this.toolCalls});
}

class ResponseFormat {
  final String type;
  final Map<String, dynamic>? jsonSchema;

  const ResponseFormat._(this.type, [this.jsonSchema]);

  factory ResponseFormat.jsonObject() => const ResponseFormat._("json_object");

  factory ResponseFormat.jsonSchema({
    required String name,
    required Map<String, dynamic> schema,
    bool strict = true,
  }) => ResponseFormat._("json_schema", {
    "name": name,
    "strict": strict,
    "schema": schema,
  });

  Map<String, dynamic> toJson() => {
    "type": type,
    if (jsonSchema != null) "json_schema": jsonSchema,
  };
}

class CreateChatCompletionRequest {
  final String model;
  final List<ChatMessage> messages;

  final String? route;
  final List<Map<String, dynamic>>? plugins;
  final Map<String, dynamic>? usage;
  final Map<String, dynamic>? provider;
  final List<String>? modalities;
  final Map<String, dynamic>? reasoning;
  final List<String>? transforms;
  final ResponseFormat? responseFormat;
  final Map<String, dynamic>? extraBody;

  final int? maxTokens;
  final double? temperature;
  final double? topP;
  final int? topK;
  final double? topA;
  final double? frequencyPenalty;
  final double? presencePenalty;
  final double? repetitionPenalty;
  final double? minP;
  final int? seed;
  final dynamic stop;

  final List<ChatTool>? tools;
  final dynamic toolChoice;

  CreateChatCompletionRequest({
    required this.model,
    required this.messages,
    this.route,
    this.plugins,
    this.usage,
    this.provider,
    this.modalities,
    this.reasoning,
    this.transforms,
    this.responseFormat,
    this.extraBody,
    this.maxTokens,
    this.temperature,
    this.topP,
    this.topK,
    this.topA,
    this.frequencyPenalty,
    this.presencePenalty,
    this.repetitionPenalty,
    this.minP,
    this.seed,
    this.stop,
    this.tools,
    this.toolChoice,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "model": model,
      "messages": messages.map((m) => m.toJson()).toList(),
    };

    if (route != null) map["route"] = route;
    if (usage != null) map["usage"] = usage;
    if (plugins != null) map["plugins"] = plugins;
    if (provider != null) map["provider"] = provider;
    if (modalities != null) map["modalities"] = modalities;
    if (reasoning != null) map["reasoning"] = reasoning;
    if (transforms != null) map["transforms"] = transforms;
    if (responseFormat != null) {
      map["response_format"] = responseFormat!.toJson();
    }
    if (maxTokens != null) map["max_tokens"] = maxTokens;
    if (temperature != null) map["temperature"] = temperature;
    if (topP != null) map["top_p"] = topP;
    if (topK != null) map["top_k"] = topK;
    if (topA != null) map["top_a"] = topA;
    if (frequencyPenalty != null) map["frequency_penalty"] = frequencyPenalty;
    if (presencePenalty != null) map["presence_penalty"] = presencePenalty;
    if (repetitionPenalty != null) {
      map["repetition_penalty"] = repetitionPenalty;
    }
    if (minP != null) map["min_p"] = minP;
    if (seed != null) map["seed"] = seed;
    if (stop != null) map["stop"] = stop;
    if (extraBody != null) map.addAll(extraBody!);

    if (tools != null) map["tools"] = tools!.map((t) => t.toJson()).toList();
    if (toolChoice != null) map["tool_choice"] = toolChoice;

    return map;
  }
}
