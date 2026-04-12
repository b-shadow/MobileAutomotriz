import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class ChangePasswordParams {
  final String id;
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.id,
    required this.currentPassword,
    required this.newPassword,
  });
}

class ChangePassword implements UseCase<void, ChangePasswordParams> {
  final ProfileRepository repository;

  ChangePassword(this.repository);

  @override
  Future<Result<void>> call(ChangePasswordParams params) {
    return repository.changePassword(
      id: params.id,
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}
