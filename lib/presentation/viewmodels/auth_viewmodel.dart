/// ViewModel de Autenticación (MVVM Pattern)
import 'package:flutter/material.dart';
import 'package:si2_mobile/data/models/auth_models.dart';
import 'package:si2_mobile/data/services/auth_service.dart';
import 'package:si2_mobile/data/services/storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService authService;
  final StorageService storageService;

  // Estado
  Usuario? _usuario;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  String? _tenantSlug;

  // Getters
  Usuario? get usuario => _usuario;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  String? get tenantSlug => _tenantSlug;

  AuthViewModel({
    required this.authService,
    required this.storageService,
  }) {
    _checkLoginStatus();
  }

  /// Verificar si hay sesión activa
  Future<void> _checkLoginStatus() async {
    final token = storageService.getToken();
    final slug = storageService.getTenantSlug();

    if (token != null && slug != null) {
      _isLoggedIn = true;
      _tenantSlug = slug;
      authService.setToken(token);
    }
    notifyListeners();
  }

  /// Login
  Future<void> login(
    String tenantSlug,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await authService.login(tenantSlug, request);

      // Guardar en storage
      await storageService.saveToken(response.accessToken);
      await storageService.saveRefreshToken(response.refreshToken);
      await storageService.saveTenantSlug(tenantSlug);

      _usuario = response.usuario;
      _isLoggedIn = true;
      _tenantSlug = tenantSlug;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register
  Future<void> register(
    String tenantSlug,
    String email,
    String password,
    String nombres,
    String apellidos,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        nombres: nombres,
        apellidos: apellidos,
        empresaNombre: tenantSlug,
        empresaSlug: tenantSlug,
      );

      final response = await authService.register(tenantSlug, request);

      // Guardar en storage
      await storageService.saveToken(response.accessToken);
      await storageService.saveRefreshToken(response.refreshToken);
      await storageService.saveTenantSlug(tenantSlug);

      _usuario = response.usuario;
      _isLoggedIn = true;
      _tenantSlug = tenantSlug;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_tenantSlug != null) {
        await authService.logout(_tenantSlug!);
      }

      await storageService.clearAll();
      authService.clearToken();

      _usuario = null;
      _isLoggedIn = false;
      _tenantSlug = null;
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

