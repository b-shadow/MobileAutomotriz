import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/user_management/domain/entities/create_user_payload.dart';
import 'package:mobile1_app/features/user_management/domain/entities/managed_user.dart';
import 'package:mobile1_app/features/user_management/domain/entities/role_option.dart';

abstract class UserManagementRepository {
  Future<Result<List<ManagedUser>>> getUsers({String? search});
  Future<Result<ManagedUser>> createUser(CreateUserPayload payload);
  Future<Result<ManagedUser>> getUserDetail(String id);
  Future<Result<Map<String, dynamic>>> changeUserRole({
    required String userId,
    required String roleId,
  });
  Future<Result<Map<String, dynamic>>> deactivateUser(String userId);
  Future<Result<Map<String, dynamic>>> activateUser(String userId);
  Future<Result<List<RoleOption>>> getRoles();
}

