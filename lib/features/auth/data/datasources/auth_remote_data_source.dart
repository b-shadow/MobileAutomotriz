import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';

import '../models/login_response_model.dart';
import '../models/usuario_model.dart';

/// Remote data source for authentication endpoints.
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<LoginResponseModel> register({
    required String email,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  });

  /// Fetch the complete user profile (includes telefono, etc.)
  Future<UsuarioModel> fetchUserProfile(String userId);

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSourceImpl({required this.apiClient});

  String get _slug => EnvConfig.tenantSlug;

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.login(_slug),
        data: {
          'email': email,
          'password': password,
        },
      );
      final json = response.data as Map<String, dynamic>;
      return LoginResponseModel.fromJson(json);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LoginResponseModel> register({
    required String email,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.register(_slug),
        data: {
          'email': email,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'password': password,
        },
      );
      return LoginResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UsuarioModel> fetchUserProfile(String userId) async {
    try {
      final response = await apiClient.get(
        ApiConstants.usuario(_slug, userId),
      );
      final json = response.data as Map<String, dynamic>;
      // ignore: avoid_print
      print('🔍 PROFILE DATA: $json');
      return UsuarioModel.fromJson(json);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiConstants.logout(_slug));
    } on ServerException {
      // Silently handle logout errors — we clear local session regardless
    } catch (_) {
      // Same: clear local session even if server call fails
    }
  }
}
