import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/user_management/domain/repositories/user_management_repository.dart';

class ActivateUser implements UseCase<Map<String, dynamic>, ActivateUserParams> {
  final UserManagementRepository repository;

  const ActivateUser(this.repository);

  @override
  Future<Result<Map<String, dynamic>>> call(ActivateUserParams params) async {
    return repository.activateUser(params.userId);
  }
}

class ActivateUserParams extends Equatable {
  final String userId;

  const ActivateUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

