/// Servicio HTTP centralizado para autenticación
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:si2_mobile/core/constants/app_constants.dart';
import 'package:si2_mobile/data/models/auth_models.dart';

class AuthService {
  final Logger logger = Logger();
  String? _token;

  /// Login: /api/tenants/{slug}/auth/login/
  Future<AuthResponse> login(String tenantSlug, LoginRequest request) async {
    try {
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.apiAuthEndpoint}/$tenantSlug/auth/login/',
      );

      logger.i('POST: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(AppConstants.connectionTimeout);

      logger.i('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        _token = authResponse.accessToken;
        return authResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Email o contraseña incorrecta');
      } else {
        throw Exception('Error en login: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Login Error: $e');
      rethrow;
    }
  }

  /// Register: /api/tenants/{slug}/auth/register/
  Future<AuthResponse> register(
    String tenantSlug,
    RegisterRequest request,
  ) async {
    try {
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.apiAuthEndpoint}/$tenantSlug/auth/register/',
      );

      logger.i('POST: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(AppConstants.connectionTimeout);

      logger.i('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        _token = authResponse.accessToken;
        return authResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Error en registro');
      }
    } catch (e) {
      logger.e('Register Error: $e');
      rethrow;
    }
  }

  /// Logout: /api/tenants/{slug}/auth/logout/
  Future<void> logout(String tenantSlug) async {
    try {
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.apiAuthEndpoint}/$tenantSlug/auth/logout/',
      );

      logger.i('POST: $url');

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(AppConstants.connectionTimeout);

      _token = null;
      logger.i('Logout exitoso');
    } catch (e) {
      logger.e('Logout Error: $e');
      // No relanzar error en logout, el usuario se desloguea de todas formas
    }
  }

  void setToken(String token) {
    _token = token;
  }

  String? getToken() => _token;

  void clearToken() {
    _token = null;
  }
}

