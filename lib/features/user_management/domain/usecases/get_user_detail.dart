import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/user_management/domain/entities/managed_user.dart';
import 'package:mobile1_app/features/user_management/domain/repositories/user_management_repository.dart';

class GetUserDetail implements UseCase<ManagedUser, GetUserDetailParams> {
  final UserManagementRepository repository;

  const GetUserDetail(this.repository);

  @override
  Future<Result<ManagedUser>> call(GetUserDetailParams params) async {
    return repository.getUserDetail(params.id);
  }
}

class GetUserDetailParams extends Equatable {
  final String id;

  const GetUserDetailParams({required this.id});

  @override
  List<Object?> get props => [id];
}

