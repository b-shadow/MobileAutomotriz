import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/user_management/data/datasources/user_management_remote_data_source.dart';
import 'package:mobile1_app/features/user_management/domain/entities/create_user_payload.dart';
import 'package:mobile1_app/features/user_management/domain/entities/managed_user.dart';
import 'package:mobile1_app/features/user_management/domain/entities/role_option.dart';
import 'package:mobile1_app/features/user_management/domain/repositories/user_management_repository.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const UserManagementRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<ManagedUser>>> getUsers({String? search}) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final rows = await remoteDataSource.getUsers(search: search);
      return Success(rows);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<ManagedUser>> createUser(CreateUserPayload payload) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final row = await remoteDataSource.createUser(payload);
      return Success(row);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<ManagedUser>> getUserDetail(String id) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final row = await remoteDataSource.getUserDetail(id);
      return Success(row);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> changeUserRole({
    required String userId,
    required String roleId,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final result = await remoteDataSource.changeUserRole(
        userId: userId,
        roleId: roleId,
      );
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> deactivateUser(String userId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final result = await remoteDataSource.deactivateUser(userId);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> activateUser(String userId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final result = await remoteDataSource.activateUser(userId);
      return Success(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<RoleOption>>> getRoles() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final rows = await remoteDataSource.getRoles();
      return Success(rows);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}

