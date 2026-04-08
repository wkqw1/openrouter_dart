class CreateRerankRequest {
  final String model;
  final String query;
  final List<String> documents;
  final int? topN;
  final Map<String, dynamic>? provider;

  CreateRerankRequest({
    required this.model,
    required this.query,
    required this.documents,
    this.topN,
    this.provider,
  });

  Map<String, dynamic> toJson() => {
    "model": model,
    "query": query,
    "documents": documents,
    if (topN != null) "top_n": topN,
    if (provider != null) "provider": provider,
  };
}

class RerankResponse {
  final String? id;
  final String model;
  final List<RerankResult> results;
  final Map<String, dynamic>? usage;

  RerankResponse({
    this.id,
    required this.model,
    required this.results,
    this.usage,
  });

  factory RerankResponse.fromJson(Map<String, dynamic> json) => RerankResponse(
    id: json["id"] as String?,
    model: json["model"] as String,
    results: (json["results"] as List)
        .map((e) => RerankResult.fromJson(e as Map<String, dynamic>))
        .toList(),
    usage: json["usage"] as Map<String, dynamic>?,
  );
}

final class RerankResult {
  final int index;
  final double relevanceScore;
  final String text;

  RerankResult({
    required this.index,
    required this.relevanceScore,
    required this.text,
  });

  factory RerankResult.fromJson(Map<String, dynamic> json) => RerankResult(
    index: (json["index"] as num).toInt(),
    relevanceScore: (json["relevance_score"] as num).toDouble(),
    text: (json["document"] as Map<String, dynamic>)["text"] as String,
  );
}
