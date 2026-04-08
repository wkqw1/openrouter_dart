import "tool_models.dart";

sealed class ChatContentPart {
  Map<String, dynamic> toJson();

  static ChatContentPart text(String text) => _TextPart(text);

  static ChatContentPart imageUrl(String url, {String? detail}) =>
      _ImagePart(url, detail);
}

final class _TextPart extends ChatContentPart {
  final String text;

  _TextPart(this.text);

  @override
  Map<String, dynamic> toJson() => {"type": "text", "text": text};
}

final class _ImagePart extends ChatContentPart {
  final String url;
  final String? detail;

  _ImagePart(this.url, this.detail);

  @override
  Map<String, dynamic> toJson() => {
    "type": "image_url",
    "image_url": {"url": url, if (detail != null) "detail": detail},
  };
}

class ChatMessage {
  final String role;
  final dynamic content;

  final String? toolCallId;
  final List<ChatToolCall>? toolCalls;

  ChatMessage({
    required this.role,
    required this.content,
    this.toolCallId,
    this.toolCalls,
  });

  factory ChatMessage.system(String content, {String? name}) =>
      ChatMessage(role: "system", content: content);

  factory ChatMessage.user(dynamic content, {String? name}) =>
      ChatMessage(role: "user", content: content);

  factory ChatMessage.assistant(String content, {String? name}) =>
      ChatMessage(role: "assistant", content: content);

  factory ChatMessage.tool(String content, String toolCallId) =>
      ChatMessage(role: "tool", content: content, toolCallId: toolCallId);

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json["role"] as String,
    content: json["content"],
    toolCallId: json["tool_call_id"] as String?,
    toolCalls: json["tool_calls"] != null
        ? (json["tool_calls"] as List)
              .map((e) => ChatToolCall.fromJson(e))
              .toList()
        : null,
  );

  Map<String, dynamic> toJson() {
    return {
      "role": role,
      "content": content is List
          ? (content as List).map((e) {
              if (e is ChatContentPart) return e.toJson();
              return e;
            }).toList()
          : content,
      if (toolCallId != null) "tool_call_id": toolCallId,
      if (toolCalls != null)
        "tool_calls": toolCalls!.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      "ChatMessage(role: $role, content: $content, toolCallId: $toolCallId, toolCalls: $toolCalls)";
}
