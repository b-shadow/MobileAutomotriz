import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/user_management/domain/repositories/user_management_repository.dart';

class ChangeUserRole implements UseCase<Map<String, dynamic>, ChangeUserRoleParams> {
  final UserManagementRepository repository;

  const ChangeUserRole(this.repository);

  @override
  Future<Result<Map<String, dynamic>>> call(ChangeUserRoleParams params) async {
    return repository.changeUserRole(userId: params.userId, roleId: params.roleId);
  }
}

class ChangeUserRoleParams extends Equatable {
  final String userId;
  final String roleId;

  const ChangeUserRoleParams({required this.userId, required this.roleId});

  @override
  List<Object?> get props => [userId, roleId];
}

