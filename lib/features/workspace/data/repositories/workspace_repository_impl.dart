import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_schedule.dart';
import 'package:mobile1_app/features/workspace/domain/entities/workspace_space.dart';
import 'package:mobile1_app/features/workspace/domain/repositories/workspace_repository.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final WorkspaceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const WorkspaceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<WorkspaceSpace>>> getSpaces() async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final rows = await remoteDataSource.getSpaces();
      return Success(rows);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkspaceSpace>> createSpace(Map<String, dynamic> data) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final row = await remoteDataSource.createSpace(data);
      return Success(row);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkspaceSpace>> updateSpaceActive({
    required String spaceId,
    required bool activo,
    String? motivo,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final row = await remoteDataSource.updateSpaceActive(
        spaceId: spaceId,
        activo: activo,
        motivo: motivo,
      );
      return Success(row);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<List<WorkspaceSchedule>>> getSpaceSchedules(String spaceId) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final rows = await remoteDataSource.getSpaceSchedules(spaceId);
      return Success(rows);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkspaceSchedule>> createSpaceSchedule({
    required String spaceId,
    required Map<String, dynamic> data,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final row = await remoteDataSource.createSpaceSchedule(
        spaceId: spaceId,
        data: data,
      );
      return Success(row);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<WorkspaceSchedule>> updateSpaceSchedule({
    required String spaceId,
    required String scheduleId,
    required Map<String, dynamic> data,
  }) async {
    if (!await networkInfo.isConnected) return const Err(NetworkFailure());

    try {
      final row = await remoteDataSource.updateSpaceSchedule(
        spaceId: spaceId,
        scheduleId: scheduleId,
        data: data,
      );
      return Success(row);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}

