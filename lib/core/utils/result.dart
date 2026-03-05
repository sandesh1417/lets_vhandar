import '../error/failure.dart';

sealed class Result<S, F extends Failure> {
  const Result();

  T when<T>({
    required T Function(S success) success,
    required T Function(F failure) failure,
  }) {
    if (this is Success<S, F>) {
      return success((this as Success<S, F>).value);
    } else {
      return failure((this as Error<S, F>).failure);
    }
  }
}

class Success<S, F extends Failure> extends Result<S, F> {
  final S value;
  const Success(this.value);
}

class Error<S, F extends Failure> extends Result<S, F> {
  final F failure;
  const Error(this.failure);
}
