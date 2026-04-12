import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/usuario_model.dart';

/// Concrete auth repository — orchestrates remote calls + local session.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SessionStorage sessionStorage;
  final ApiClient apiClient;
  final NetworkInfo networkInfo;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sessionStorage,
    required this.apiClient,
    required this.networkInfo,
  });

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Set access token BEFORE fetching profile
      apiClient.setAuthToken(response.accessToken);

      // Fetch complete user profile (includes telefono, etc.)
      final fullUser = await _fetchFullProfile(response.usuario.id) 
          ?? response.usuario;

      // The profile endpoint might not include tenant data, so we merge it
      // back from the login response root before saving to cache.
      final userWithTenant = fullUser.copyWith(
        empresaId: response.usuario.empresaId,
        empresaNombre: response.usuario.empresaNombre,
        empresaSlug: response.usuario.empresaSlug,
      );

      // Persist session locally with complete data
      await sessionStorage.saveSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userData: userWithTenant.toJson(),
      );

      return Success(AuthSession(
        token: response.accessToken,
        user: userWithTenant,
      ));
    } on ServerException catch (e) {
      return Err(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    }
  }

  @override
  Future<Result<AuthSession>> register({
    required String email,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.register(
        email: email,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        password: password,
      );

      // Set access token BEFORE fetching profile
      apiClient.setAuthToken(response.accessToken);

      // Fetch complete user profile
      final fullUser = await _fetchFullProfile(response.usuario.id) 
          ?? response.usuario;

      // Persist session locally with complete data
      await sessionStorage.saveSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userData: fullUser.toJson(),
      );

      return Success(AuthSession(
        token: response.accessToken,
        user: fullUser,
      ));
    } on ServerException catch (e) {
      return Err(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      // Call server logout (invalidate token server-side)
      await remoteDataSource.logout();
    } catch (_) {
      // Ignore server errors — always clear local session
    }

    // Always clear local session
    await sessionStorage.clearSession();
    apiClient.clearAuthToken();

    return const Success(null);
  }

  Future<UsuarioModel?> _fetchFullProfile(String userId) async {
    try {
      return await remoteDataSource.fetchUserProfile(userId);
    } catch (_) {
      // If fetching full profile fails, fallback to partial user data from login
      return null;
    }
  }
}
