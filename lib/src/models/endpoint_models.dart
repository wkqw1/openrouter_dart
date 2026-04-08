class ModelEndpointsResponse {
  final String id;
  final String name;
  final String description;
  final List<ModelEndpoint> endpoints;

  ModelEndpointsResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.endpoints,
  });

  factory ModelEndpointsResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"] as Map<String, dynamic>;
    return ModelEndpointsResponse(
      id: data["id"] as String,
      name: data["name"] as String,
      description: data["description"] as String? ?? "",
      endpoints: (data["endpoints"] as List)
          .map((e) => ModelEndpoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ModelEndpoint {
  final String name;
  final String modelId;
  final String providerName;
  final int contextLength;
  final Map<String, dynamic> pricing;
  final List<String> supportedParameters;

  ModelEndpoint({
    required this.name,
    required this.modelId,
    required this.providerName,
    required this.contextLength,
    required this.pricing,
    required this.supportedParameters,
  });

  factory ModelEndpoint.fromJson(Map<String, dynamic> json) => ModelEndpoint(
    name: json["name"] as String,
    modelId: json["model_id"] as String,
    providerName: json["provider_name"] as String,
    contextLength: (json["context_length"] as num).toInt(),
    pricing: json["pricing"] as Map<String, dynamic>,
    supportedParameters:
        (json["supported_parameters"] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
  );
}
