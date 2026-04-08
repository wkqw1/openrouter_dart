import "dart:convert";

enum EmbeddingEncodingFormat {
  float("float"),
  base64("base64");

  final String value;
  const EmbeddingEncodingFormat(this.value);

  @override
  String toString() => value;
}

class EmbeddingInput {
  final dynamic data;

  EmbeddingInput._(this.data);

  factory EmbeddingInput.text(String text) => EmbeddingInput._(text);

  factory EmbeddingInput.texts(List<String> texts) => EmbeddingInput._(texts);

  factory EmbeddingInput.tokens(List<int> tokens) => EmbeddingInput._(tokens);

  factory EmbeddingInput.tokensBatch(List<List<int>> batches) =>
      EmbeddingInput._(batches);

  factory EmbeddingInput.multimodal(List<Map<String, dynamic>> items) =>
      EmbeddingInput._(items);

  dynamic toJson() => data;

  @override
  String toString() => "EmbeddingInput(data: $data)";
}

class CreateEmbeddingRequest {
  final String model;
  final EmbeddingInput input;
  final EmbeddingEncodingFormat? encodingFormat;
  final int? dimensions;
  final String? user;
  final Map<String, dynamic>? provider;
  final String? inputType;

  const CreateEmbeddingRequest({
    required this.model,
    required this.input,
    this.encodingFormat,
    this.dimensions,
    this.user,
    this.provider,
    this.inputType,
  });

  Map<String, dynamic> toJson() {
    return {
      "model": model,
      "input": input.toJson(),
      if (encodingFormat != null) "encoding_format": encodingFormat!.value,
      if (dimensions != null) "dimensions": dimensions,
      if (user != null) "user": user,
      if (provider != null) "provider": provider,
      if (inputType != null) "input_type": inputType,
    };
  }
}

sealed class EmbeddingVector {
  const EmbeddingVector();

  factory EmbeddingVector.fromJson(dynamic json) {
    if (json is List) {
      return FloatEmbeddingVector(
        json.map((e) => (e as num).toDouble()).toList(),
      );
    }
    if (json is String) {
      return Base64EmbeddingVector(json);
    }
    throw ArgumentError("Unknown embedding vector format: ${json.runtimeType}");
  }
}

class FloatEmbeddingVector extends EmbeddingVector {
  final List<double> values;
  const FloatEmbeddingVector(this.values);

  @override
  String toString() => "FloatVector(${values.length} dims)";
}

class Base64EmbeddingVector extends EmbeddingVector {
  final String data;
  const Base64EmbeddingVector(this.data);

  List<double> decode() {
    final bytes = base64Decode(data);
    return bytes.buffer.asFloat32List().toList();
  }

  @override
  String toString() => "Base64Vector(${data.length} chars)";
}

class EmbeddingObject {
  final List<double> values;
  final int index;

  EmbeddingObject({required this.values, required this.index});

  factory EmbeddingObject.fromJson(Map<String, dynamic> json) {
    final vector = EmbeddingVector.fromJson(json["embedding"]);

    final List<double> floatValues = switch (vector) {
      FloatEmbeddingVector(values: final v) => v,
      Base64EmbeddingVector() => vector.decode(),
    };

    return EmbeddingObject(
      values: floatValues,
      index: (json["index"] as num).toInt(),
    );
  }
}

class EmbeddingUsage {
  final int promptTokens;
  final int totalTokens;

  EmbeddingUsage({required this.promptTokens, required this.totalTokens});

  factory EmbeddingUsage.fromJson(Map<String, dynamic> json) => EmbeddingUsage(
    promptTokens: (json["prompt_tokens"] as num?)?.toInt() ?? 0,
    totalTokens: (json["total_tokens"] as num?)?.toInt() ?? 0,
  );
}

class EmbeddingResponse {
  final String model;
  final List<EmbeddingObject> data;
  final EmbeddingUsage? usage;
  final Map<String, dynamic> raw;

  EmbeddingResponse({
    required this.model,
    required this.data,
    this.usage,
    required this.raw,
  });

  List<double> get embedding => data.first.values;

  factory EmbeddingResponse.fromJson(Map<String, dynamic> json) =>
      EmbeddingResponse(
        model: json["model"] as String,
        data: (json["data"] as List)
            .map((e) => EmbeddingObject.fromJson(e as Map<String, dynamic>))
            .toList(),
        usage: json["usage"] != null
            ? EmbeddingUsage.fromJson(json["usage"])
            : null,
        raw: json,
      );
}
