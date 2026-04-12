/// Custom exception for server/API errors.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

/// Custom exception for local cache errors.
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Custom exception for network connectivity errors.
class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Sin conexión a internet'});

  @override
  String toString() => 'NetworkException(message: $message)';
}
