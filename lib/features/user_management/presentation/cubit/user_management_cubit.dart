import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/user_management/domain/entities/create_user_payload.dart';
import 'package:mobile1_app/features/user_management/domain/entities/managed_user.dart';
import 'package:mobile1_app/features/user_management/domain/entities/role_option.dart';
import 'package:mobile1_app/features/user_management/domain/usecases/activate_user.dart';
import 'package:mobile1_app/features/user_management/domain/usecases/change_user_role.dart';
import 'package:mobile1_app/features/user_management/domain/usecases/create_user.dart';
import 'package:mobile1_app/features/user_management/domain/usecases/deactivate_user.dart';
import 'package:mobile1_app/features/user_management/domain/usecases/get_roles.dart';
import 'package:mobile1_app/features/user_management/domain/usecases/get_users.dart';

import 'user_management_state.dart';

class UserManagementCubit extends Cubit<UserManagementState> {
  final GetUsers _getUsers;
  final GetRoles _getRoles;
  final CreateUser _createUser;
  final ChangeUserRole _changeUserRole;
  final ActivateUser _activateUser;
  final DeactivateUser _deactivateUser;

  List<ManagedUser> _users = const [];
  List<RoleOption> _roles = const [];
  String _search = '';

  UserManagementCubit({
    required GetUsers getUsers,
    required GetRoles getRoles,
    required CreateUser createUser,
    required ChangeUserRole changeUserRole,
    required ActivateUser activateUser,
    required DeactivateUser deactivateUser,
  })  : _getUsers = getUsers,
        _getRoles = getRoles,
        _createUser = createUser,
        _changeUserRole = changeUserRole,
        _activateUser = activateUser,
        _deactivateUser = deactivateUser,
        super(const UserManagementInitial());

  Future<void> fetchInitial() async {
    emit(const UserManagementLoading());

    final rolesResult = await _getRoles(const NoParams());
    if (rolesResult is Success<List<RoleOption>>) {
      _roles = rolesResult.data;
    }

    await _fetchUsers();
  }

  Future<void> searchUsers(String text) async {
    _search = text.trim();
    emit(const UserManagementLoading());
    await _fetchUsers();
  }

  Future<void> createUser(CreateUserPayload payload) async {
    final result = await _createUser(CreateUserParams(payload: payload));
    switch (result) {
      case Success():
        await _fetchUsers();
        emit(UserManagementSuccess(
          message: 'Usuario creado correctamente.',
          users: _users,
          roles: _roles,
          search: _search,
        ));
        emit(_loadedState());
      case Err(:final failure):
        emit(UserManagementError(
          message: failure.message,
          users: _users,
          roles: _roles,
          search: _search,
        ));
    }
  }

  Future<void> changeRole({
    required String userId,
    required String roleId,
  }) async {
    final result = await _changeUserRole(
      ChangeUserRoleParams(userId: userId, roleId: roleId),
    );

    switch (result) {
      case Success():
        await _fetchUsers();
        emit(UserManagementSuccess(
          message: 'Rol actualizado correctamente.',
          users: _users,
          roles: _roles,
          search: _search,
        ));
        emit(_loadedState());
      case Err(:final failure):
        emit(UserManagementError(
          message: failure.message,
          users: _users,
          roles: _roles,
          search: _search,
        ));
    }
  }

  Future<void> deactivate(String userId) async {
    final result = await _deactivateUser(DeactivateUserParams(userId: userId));
    switch (result) {
      case Success():
        await _fetchUsers();
        emit(UserManagementSuccess(
          message: 'Usuario desactivado.',
          users: _users,
          roles: _roles,
          search: _search,
        ));
        emit(_loadedState());
      case Err(:final failure):
        emit(UserManagementError(
          message: failure.message,
          users: _users,
          roles: _roles,
          search: _search,
        ));
    }
  }

  Future<void> activate(String userId) async {
    final result = await _activateUser(ActivateUserParams(userId: userId));
    switch (result) {
      case Success():
        await _fetchUsers();
        emit(UserManagementSuccess(
          message: 'Usuario activado.',
          users: _users,
          roles: _roles,
          search: _search,
        ));
        emit(_loadedState());
      case Err(:final failure):
        emit(UserManagementError(
          message: failure.message,
          users: _users,
          roles: _roles,
          search: _search,
        ));
    }
  }

  Future<void> _fetchUsers() async {
    final result = await _getUsers(GetUsersParams(search: _search));
    switch (result) {
      case Success(:final data):
        _users = data;
        emit(_loadedState());
      case Err(:final failure):
        emit(UserManagementError(
          message: failure.message,
          users: _users,
          roles: _roles,
          search: _search,
        ));
    }
  }

  UserManagementLoaded _loadedState() {
    return UserManagementLoaded(users: _users, roles: _roles, search: _search);
  }
}

