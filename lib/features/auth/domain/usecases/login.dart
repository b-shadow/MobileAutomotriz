import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Use case: Login with email and password.
class Login extends UseCase<AuthSession, LoginParams> {
  final AuthRepository repository;

  Login(this.repository);

  @override
  Future<Result<AuthSession>> call(LoginParams params) {
    return repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
