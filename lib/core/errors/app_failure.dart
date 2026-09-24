/// Base type for domain/presentation failures.
sealed class AppFailure {
  const AppFailure(this.message);

  final String message;
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network unavailable.']);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}
