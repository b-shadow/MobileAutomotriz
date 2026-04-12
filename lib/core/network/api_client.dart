import 'package:dio/dio.dart';

import '../../config/env/env_config.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';

/// Centralized HTTP client for the automotive SaaS backend.
///
/// Features:
/// - Automatic Bearer token injection
/// - Tenant-aware URL building
/// - Django REST Framework error parsing
/// - Debug logging
/// - Flutter Web (CORS) compatible
class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? EnvConfig.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        responseType: ResponseType.json, // Explicit for web compatibility
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (EnvConfig.isDebug) {
      _dio.interceptors.add(_LoggingInterceptor());
    }
  }

  /// The underlying Dio instance.
  Dio get dio => _dio;

  // ── Auth Token ─────────────────────────────────────────

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  bool get hasAuthToken => _dio.options.headers.containsKey('Authorization');

  // ── HTTP Methods ───────────────────────────────────────

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<dynamic>> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ── Error Handling (Django REST Framework) ─────────────

  ServerException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException(
          message: 'Tiempo de conexión agotado',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return _parseDjangoError(e);
      case DioExceptionType.cancel:
        return const ServerException(message: 'Solicitud cancelada');
      case DioExceptionType.connectionError:
        return const ServerException(
          message: 'No se pudo conectar al servidor. Verifica tu conexión.',
        );
      case DioExceptionType.badCertificate:
        return const ServerException(
          message: 'Error de certificado SSL',
        );
      case DioExceptionType.unknown:
        // On web, CORS errors manifest as DioExceptionType.unknown
        // with null response and a browser XMLHttpRequest error object.
        final errorMsg = e.error?.toString() ?? '';
        if (errorMsg.contains('XMLHttpRequest') ||
            errorMsg.contains('CORS') ||
            e.response == null) {
          return const ServerException(
            message:
                'Error de conexión (posible CORS). '
                'Si estás en web, usa un emulador Android o configura CORS en el backend.',
          );
        }
        return ServerException(
          message: e.message ?? 'Error de red desconocido',
        );
    }
  }

  /// Parse Django REST Framework error responses into readable messages.
  ///
  /// Handles two formats:
  /// - `{ "detail": "Error message" }`
  /// - `{ "field": ["error1", "error2"], ... }`
  ServerException _parseDjangoError(DioException e) {
    final statusCode = e.response?.statusCode ?? 500;
    final data = e.response?.data;

    if (data == null) {
      return ServerException(
        message: _defaultMessageForStatus(statusCode),
        statusCode: statusCode,
      );
    }

    if (data is Map<String, dynamic>) {
      // Format 1: { "detail": "message" }
      if (data.containsKey('detail')) {
        return ServerException(
          message: data['detail'].toString(),
          statusCode: statusCode,
        );
      }

      // Format 2: { "field": ["error1"], "field2": ["error2"] }
      final errors = <String>[];
      data.forEach((key, value) {
        if (value is List) {
          for (final msg in value) {
            errors.add('$msg');
          }
        } else {
          errors.add('$value');
        }
      });

      if (errors.isNotEmpty) {
        return ServerException(
          message: errors.join('\n'),
          statusCode: statusCode,
        );
      }
    }

    return ServerException(
      message: _defaultMessageForStatus(statusCode),
      statusCode: statusCode,
    );
  }

  String _defaultMessageForStatus(int statusCode) {
    return switch (statusCode) {
      400 => 'Datos inválidos',
      401 => 'No autorizado. Inicia sesión nuevamente.',
      403 => 'No tienes permiso para esta acción',
      404 => 'Recurso no encontrado',
      409 => 'Conflicto con datos existentes',
      422 => 'Operación no permitida',
      500 => 'Error interno del servidor',
      _ => 'Error del servidor ($statusCode)',
    };
  }
}

// ── Logging Interceptor (Debug only) ───────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('┌── API ▶ ${options.method} ${options.uri}');
    if (options.data != null) {
      // ignore: avoid_print
      print('│ Body: ${options.data}');
    }
    // ignore: avoid_print
    print('└──────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('┌── API ◀ ${response.statusCode} ${response.requestOptions.uri}');
    // ignore: avoid_print
    print('│ Data type: ${response.data.runtimeType}');
    // ignore: avoid_print
    print('└──────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('┌── API ✖ ${err.requestOptions.uri}');
    // ignore: avoid_print
    print('│ Type: ${err.type}');
    // ignore: avoid_print
    print('│ Status: ${err.response?.statusCode}');
    // ignore: avoid_print
    print('│ Message: ${err.message}');
    // ignore: avoid_print
    print('│ Error: ${err.error}');
    // ignore: avoid_print
    print('│ Error runtimeType: ${err.error.runtimeType}');
    // ignore: avoid_print
    print('└──────────────────────────────────────────');
    handler.next(err);
  }
}
