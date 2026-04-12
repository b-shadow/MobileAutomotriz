import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/user_management/domain/entities/role_option.dart';
import 'package:mobile1_app/features/user_management/domain/repositories/user_management_repository.dart';

class GetRoles implements UseCase<List<RoleOption>, NoParams> {
  final UserManagementRepository repository;

  const GetRoles(this.repository);

  @override
  Future<Result<List<RoleOption>>> call(NoParams params) async {
    return repository.getRoles();
  }
}

