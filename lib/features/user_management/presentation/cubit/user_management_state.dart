import 'package:mobile1_app/features/user_management/domain/entities/managed_user.dart';
import 'package:mobile1_app/features/user_management/domain/entities/role_option.dart';

abstract class UserManagementState {
  const UserManagementState();
}

class UserManagementInitial extends UserManagementState {
  const UserManagementInitial();
}

class UserManagementLoading extends UserManagementState {
  const UserManagementLoading();
}

class UserManagementLoaded extends UserManagementState {
  final List<ManagedUser> users;
  final List<RoleOption> roles;
  final String search;

  const UserManagementLoaded({
    required this.users,
    required this.roles,
    required this.search,
  });
}

class UserManagementSuccess extends UserManagementState {
  final String message;
  final List<ManagedUser> users;
  final List<RoleOption> roles;
  final String search;

  const UserManagementSuccess({
    required this.message,
    required this.users,
    required this.roles,
    required this.search,
  });
}

class UserManagementError extends UserManagementState {
  final String message;
  final List<ManagedUser> users;
  final List<RoleOption> roles;
  final String search;

  const UserManagementError({
    required this.message,
    required this.users,
    required this.roles,
    required this.search,
  });
}

