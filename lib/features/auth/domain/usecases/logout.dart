import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';

import '../repositories/auth_repository.dart';

/// Use case: Logout and clear the current session.
class Logout extends UseCase<void, NoParams> {
  final AuthRepository repository;

  Logout(this.repository);

  @override
  Future<Result<void>> call(NoParams params) {
    return repository.logout();
  }
}
