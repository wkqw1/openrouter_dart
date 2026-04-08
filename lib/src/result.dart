class OpenRouterResult<S, F extends Exception> {
  const OpenRouterResult();

  bool get isSuccess => this is Success<S, F>;
  bool get isFailure => this is Failure<S, F>;

  T to<T>({
    required T Function(S value) onSuccess,
    required T Function(F error) onFailure,
  }) => switch (this) {
    Success<S, F>(:final value) => onSuccess(value),
    Failure<S, F>(:final error) => onFailure(error),
    OpenRouterResult<S, F>() => throw UnimplementedError(),
  };
}

class Success<S, F extends Exception> extends OpenRouterResult<S, F> {
  final S value;

  const Success(this.value);

  @override
  String toString() => "Success($value)";
}

class Failure<S, F extends Exception> extends OpenRouterResult<S, F> {
  final F error;

  const Failure(this.error);

  @override
  String toString() => "Failure($error)";
}
