import 'failures.dart';

/// A Result type using Dart 3 sealed classes.
/// Replaces dartz/fpdart Either with a native, idiomatic approach.
///
/// Usage with pattern matching:
/// ```dart
/// switch (result) {
///   case Success(:final data):
///     // handle success
///   case Err(:final failure):
///     // handle error
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// Represents a successful result containing [data].
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

/// Represents a failed result containing a [Failure].
final class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);
}
