import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/user_management/domain/entities/managed_user.dart';
import 'package:mobile1_app/features/user_management/domain/repositories/user_management_repository.dart';

class GetUsers implements UseCase<List<ManagedUser>, GetUsersParams> {
  final UserManagementRepository repository;

  const GetUsers(this.repository);

  @override
  Future<Result<List<ManagedUser>>> call(GetUsersParams params) async {
    return repository.getUsers(search: params.search);
  }
}

class GetUsersParams extends Equatable {
  final String? search;

  const GetUsersParams({this.search});

  @override
  List<Object?> get props => [search];
}

