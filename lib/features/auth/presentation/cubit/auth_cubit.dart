import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';

import '../../data/models/usuario_model.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register_user.dart';
import 'auth_state.dart';

/// Global auth cubit managing authentication state.
///
/// Provided at the app level so all routes can react to auth changes.
class AuthCubit extends Cubit<AuthState> {
  final Login _login;
  final RegisterUser _registerUser;
  final Logout _logout;
  final SessionStorage _sessionStorage;
  final ApiClient _apiClient;

  AuthCubit({
    required Login login,
    required RegisterUser registerUser,
    required Logout logout,
    required SessionStorage sessionStorage,
    required ApiClient apiClient,
  })  : _login = login,
        _registerUser = registerUser,
        _logout = logout,
        _sessionStorage = sessionStorage,
        _apiClient = apiClient,
        super(const AuthInitial());

  /// Check if there's a saved session on app startup.
  void checkAuthStatus() {
    if (_sessionStorage.isLoggedIn) {
      final userData = _sessionStorage.userData;
      if (userData != null) {
        final user = UsuarioModel.fromJson(userData);
        _apiClient.setAuthToken(_sessionStorage.accessToken!);
        emit(AuthAuthenticated(user: user));
        return;
      }
    }
    emit(const AuthUnauthenticated());
  }

  /// Authenticate with email and password.
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await _login(
      LoginParams(email: email, password: password),
    );

    switch (result) {
      case Success<AuthSession>(:final data):
        emit(AuthAuthenticated(user: data.user));
      case Err<AuthSession>(:final failure):
        emit(AuthError(message: failure.message));
    }
  }

  /// Register a new account.
  Future<void> registerNewUser({
    required String email,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await _registerUser(
      RegisterParams(
        email: email,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        password: password,
      ),
    );

    switch (result) {
      case Success<AuthSession>(:final data):
        emit(AuthAuthenticated(user: data.user));
      case Err<AuthSession>(:final failure):
        emit(AuthError(message: failure.message));
    }
  }

  /// Logout and clear session.
  Future<void> logoutUser() async {
    emit(const AuthLoading());

    await _logout(const NoParams());

    emit(const AuthUnauthenticated());
  }

  /// Update the current authenticated user in the global session.
  Future<void> updateUser(UsuarioModel updatedUser) async {
    // Only update if currently authenticated
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user as UsuarioModel;
      
      // Merge properties. If updatedUser fields are empty '' (due to API not returning them),
      // we fallback to the current user's values.
      final mergedUser = currentUser.copyWith(
        id: updatedUser.id.isNotEmpty ? updatedUser.id : currentUser.id,
        email: updatedUser.email.isNotEmpty ? updatedUser.email : currentUser.email,
        nombres: updatedUser.nombres.isNotEmpty ? updatedUser.nombres : currentUser.nombres,
        apellidos: updatedUser.apellidos.isNotEmpty ? updatedUser.apellidos : currentUser.apellidos,
        telefono: updatedUser.telefono, // nullable, so we take the new one directly
        rolId: updatedUser.rolId.isNotEmpty ? updatedUser.rolId : currentUser.rolId,
        rolNombre: updatedUser.rolNombre.isNotEmpty ? updatedUser.rolNombre : currentUser.rolNombre,
        empresaId: updatedUser.empresaId.isNotEmpty ? updatedUser.empresaId : currentUser.empresaId,
        empresaNombre: updatedUser.empresaNombre.isNotEmpty ? updatedUser.empresaNombre : currentUser.empresaNombre,
        empresaSlug: updatedUser.empresaSlug.isNotEmpty ? updatedUser.empresaSlug : currentUser.empresaSlug,
        isActive: updatedUser.isActive,
        notiEmail: updatedUser.notiEmail,
        notiPush: updatedUser.notiPush,
      );

      // Save it locally
      await _sessionStorage.saveUserData(mergedUser.toJson());
      // Emit new authenticated state with updated user
      emit(AuthAuthenticated(user: mergedUser));
    }
  }
}
