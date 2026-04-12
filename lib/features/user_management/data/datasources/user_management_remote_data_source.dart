import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/user_management/data/models/managed_user_model.dart';
import 'package:mobile1_app/features/user_management/data/models/role_option_model.dart';
import 'package:mobile1_app/features/user_management/domain/entities/create_user_payload.dart';

abstract class UserManagementRemoteDataSource {
  Future<List<ManagedUserModel>> getUsers({String? search});
  Future<ManagedUserModel> createUser(CreateUserPayload payload);
  Future<ManagedUserModel> getUserDetail(String id);
  Future<Map<String, dynamic>> changeUserRole({
    required String userId,
    required String roleId,
  });
  Future<Map<String, dynamic>> deactivateUser(String userId);
  Future<Map<String, dynamic>> activateUser(String userId);
  Future<List<RoleOptionModel>> getRoles();
}

class UserManagementRemoteDataSourceImpl implements UserManagementRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const UserManagementRemoteDataSourceImpl({
    required this.apiClient,
    required this.sessionStorage,
  });

  String get _slug {
    final userData = sessionStorage.userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      final slug = tenant['slug'] as String?;
      if (slug != null && slug.isNotEmpty) return slug;
    }
    return EnvConfig.tenantSlug;
  }

  @override
  Future<List<ManagedUserModel>> getUsers({String? search}) async {
    try {
      final params = <String, dynamic>{};
      if ((search ?? '').trim().isNotEmpty) {
        params['search'] = search!.trim();
      }

      final response = await apiClient.get(
        ApiConstants.usuarios(_slug),
        queryParameters: params.isEmpty ? null : params,
      );

      final data = response.data;
      final List<dynamic> rows;
      if (data is Map<String, dynamic> && data['results'] is List) {
        rows = data['results'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        rows = data;
      } else {
        rows = const [];
      }

      return rows
          .whereType<Map<String, dynamic>>()
          .map(ManagedUserModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ManagedUserModel> createUser(CreateUserPayload payload) async {
    try {
      final response = await apiClient.post(
        ApiConstants.usuarios(_slug),
        data: payload.toJson(),
      );
      return ManagedUserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ManagedUserModel> getUserDetail(String id) async {
    try {
      final response = await apiClient.get(ApiConstants.usuario(_slug, id));
      return ManagedUserModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> changeUserRole({
    required String userId,
    required String roleId,
  }) async {
    try {
      final response = await apiClient.patch(
        ApiConstants.cambiarRol(_slug, userId),
        data: {'rol_id': roleId},
      );
      return response.data as Map<String, dynamic>;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> deactivateUser(String userId) async {
    try {
      final response = await apiClient.patch(
        ApiConstants.desactivarUsuario(_slug, userId),
      );
      return response.data as Map<String, dynamic>;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> activateUser(String userId) async {
    try {
      final response = await apiClient.patch(
        ApiConstants.activarUsuario(_slug, userId),
      );
      return response.data as Map<String, dynamic>;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<RoleOptionModel>> getRoles() async {
    try {
      final response = await apiClient.get(ApiConstants.obtenerRoles(_slug));
      final data = response.data;

      final List<dynamic> rows;
      if (data is Map<String, dynamic> && data['results'] is List) {
        rows = data['results'] as List<dynamic>;
      } else if (data is Map<String, dynamic> && data['roles'] is List) {
        rows = data['roles'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        rows = data;
      } else {
        rows = const [];
      }

      return rows
          .whereType<Map<String, dynamic>>()
          .map(RoleOptionModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}


