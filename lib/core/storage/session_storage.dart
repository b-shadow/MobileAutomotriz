import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistent storage for the user session (tokens + user data).
///
/// Uses SharedPreferences for simple key-value persistence.
/// Can be upgraded to flutter_secure_storage for production.
class SessionStorage {
  final SharedPreferences _prefs;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  SessionStorage(this._prefs);

  // ── Access Token ───────────────────────────────────────

  /// Save the JWT access token.
  Future<void> saveAccessToken(String token) async {
    await _prefs.setString(_accessTokenKey, token);
  }

  /// Get the saved JWT access token, or null if not logged in.
  String? get accessToken => _prefs.getString(_accessTokenKey);

  // ── Refresh Token ──────────────────────────────────────

  /// Save the JWT refresh token.
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  /// Get the saved JWT refresh token.
  String? get refreshToken => _prefs.getString(_refreshTokenKey);

  // ── User Data ──────────────────────────────────────────

  /// Save user data as JSON string.
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userKey, jsonEncode(userData));
  }

  /// Get saved user data, or null if not available.
  Map<String, dynamic>? get userData {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Session Management ─────────────────────────────────

  /// Save a complete session (tokens + user data).
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    await saveUserData(userData);
  }

  /// Clear the entire session (logout).
  Future<void> clearSession() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userKey);
  }

  /// Whether a session exists (user is logged in).
  bool get isLoggedIn => _prefs.containsKey(_accessTokenKey);
}
