import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/user_management/domain/repositories/user_management_repository.dart';

class DeactivateUser implements UseCase<Map<String, dynamic>, DeactivateUserParams> {
  final UserManagementRepository repository;

  const DeactivateUser(this.repository);

  @override
  Future<Result<Map<String, dynamic>>> call(DeactivateUserParams params) async {
    return repository.deactivateUser(params.userId);
  }
}

class DeactivateUserParams extends Equatable {
  final String userId;

  const DeactivateUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

