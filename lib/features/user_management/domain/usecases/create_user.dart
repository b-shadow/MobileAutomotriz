import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/user_management/domain/entities/create_user_payload.dart';
import 'package:mobile1_app/features/user_management/domain/entities/managed_user.dart';
import 'package:mobile1_app/features/user_management/domain/repositories/user_management_repository.dart';

class CreateUser implements UseCase<ManagedUser, CreateUserParams> {
  final UserManagementRepository repository;

  const CreateUser(this.repository);

  @override
  Future<Result<ManagedUser>> call(CreateUserParams params) async {
    return repository.createUser(params.payload);
  }
}

class CreateUserParams extends Equatable {
  final CreateUserPayload payload;

  const CreateUserParams({required this.payload});

  @override
  List<Object?> get props => [payload];
}

