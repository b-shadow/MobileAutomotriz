import 'package:equatable/equatable.dart';

import 'user.dart';

/// Represents a successful authentication result (login or register).
class AuthSession extends Equatable {
  final String token;
  final User user;

  const AuthSession({required this.token, required this.user});

  @override
  List<Object?> get props => [token, user];
}
