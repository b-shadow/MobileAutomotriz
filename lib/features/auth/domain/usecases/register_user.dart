import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Use case: Register a new user account.
class RegisterUser extends UseCase<AuthSession, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Result<AuthSession>> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      nombres: params.nombres,
      apellidos: params.apellidos,
      telefono: params.telefono,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String password;

  const RegisterParams({
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.password,
  });

  @override
  List<Object?> get props => [email, nombres, apellidos, telefono, password];
}
