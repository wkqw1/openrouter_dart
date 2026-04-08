class OpenRouterModelInfo {
  final String id;
  final String name;
  final String description;
  final int contextLength;
  final Map<String, dynamic> pricing;

  OpenRouterModelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.contextLength,
    required this.pricing,
  });

  factory OpenRouterModelInfo.fromJson(Map<String, dynamic> json) =>
      OpenRouterModelInfo(
        id: json["id"] as String,
        name: json["name"] as String,
        description: json["description"] as String? ?? "",
        contextLength: (json["context_length"] as num).toInt(),
        pricing: json["pricing"] as Map<String, dynamic>,
      );
}
