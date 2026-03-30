/// Servicio de almacenamiento local
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si2_mobile/core/constants/app_constants.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(AppConstants.refreshTokenKey, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }

  // Tenant Slug
  Future<void> saveTenantSlug(String slug) async {
    await _prefs.setString(AppConstants.tenantSlugKey, slug);
  }

  String? getTenantSlug() {
    return _prefs.getString(AppConstants.tenantSlugKey);
  }

  // Limpiar todo
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  bool isLoggedIn() {
    return getToken() != null;
  }
}

