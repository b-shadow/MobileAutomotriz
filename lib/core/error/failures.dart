import 'package:equatable/equatable.dart';

/// Base failure class using Dart 3 sealed classes for exhaustive matching.
sealed class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Failure originating from a server/API error.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure originating from a local cache error.
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failure originating from a network connectivity issue.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Sin conexión a internet'});
}
