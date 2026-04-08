class ChatTool {
  final String name;
  final String? description;

  final Map<String, dynamic> parameters;

  ChatTool({required this.name, this.description, required this.parameters});

  Map<String, dynamic> toJson() => {
    "type": "function",
    "function": {
      "name": name,
      if (description != null) "description": description,
      "parameters": parameters,
    },
  };
}

class ChatToolCall {
  final String id;
  final String type;
  final String functionName;
  final String arguments;

  ChatToolCall({
    required this.id,
    this.type = "function",
    required this.functionName,
    required this.arguments,
  });

  factory ChatToolCall.fromJson(Map<String, dynamic> json) {
    final function = json["function"] as Map<String, dynamic>;
    return ChatToolCall(
      id: json["id"] as String,
      type: json["type"] as String? ?? "function",
      functionName: function["name"] as String,
      arguments: function["arguments"] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "function": {"name": functionName, "arguments": arguments},
  };
}
