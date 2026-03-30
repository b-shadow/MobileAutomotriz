/// Constantes de la aplicación
class AppConstants {
  // API
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String apiAuthEndpoint = '/api/tenants';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String tenantSlugKey = 'tenant_slug';
}

