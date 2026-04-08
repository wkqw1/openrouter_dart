class OpenRouterException implements Exception {
  final String message;

  OpenRouterException(this.message);

  @override
  String toString() => "$runtimeType: $message";
}

class OpenRouterApiException extends OpenRouterException {
  final int? statusCode;
  final dynamic data;

  OpenRouterApiException({required String message, this.statusCode, this.data})
    : super(message);

  @override
  String toString() =>
      "OpenRouterApiException(statusCode: $statusCode, message: $message)";
}

class OpenRouterNetworkException extends OpenRouterException {
  OpenRouterNetworkException(super.message);

  @override
  String toString() => "OpenRouterNetworkException: $message";
}

class OpenRouterTimeoutException extends OpenRouterException {
  OpenRouterTimeoutException(super.message);

  @override
  String toString() => "OpenRouterTimeoutException: $message";
}

class OpenRouterUnknownException extends OpenRouterException {
  final Object error;

  final StackTrace stackTrace;

  OpenRouterUnknownException({
    required String message,
    required this.error,
    required this.stackTrace,
  }) : super(message);

  @override
  String toString() => "OpenRouterUnknownException: $message\n$stackTrace";
}
