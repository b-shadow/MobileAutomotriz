import 'package:mobile1_app/core/error/result.dart';

import '../entities/auth_session.dart';

/// Auth repository contract — domain layer.
abstract class AuthRepository {
  /// Login with email and password.
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  /// Register a new user account.
  Future<Result<AuthSession>> register({
    required String email,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String password,
  });

  /// Logout and invalidate the current session.
  Future<Result<void>> logout();
}
