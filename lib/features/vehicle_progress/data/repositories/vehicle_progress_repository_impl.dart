import '../../../../core/network/network_info.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/failures.dart';
import '../../../workshop_progress/domain/entities/progress_log.dart';
import '../../domain/entities/vehicle_progress.dart';
import '../../domain/entities/vehicle_progress_detail.dart';
import '../../domain/repositories/vehicle_progress_repository.dart';
import '../datasources/vehicle_progress_remote_data_source.dart';

class VehicleProgressRepositoryImpl implements VehicleProgressRepository {
  final VehicleProgressRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VehicleProgressRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<VehicleProgress>>> getOperativeAppointments() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.getOperativeAppointments();
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<VehicleProgressDetail>> getVehicleProgressDetail(String citaId) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.getVehicleProgressDetail(citaId);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<VehicleProgressDetail>> registerArrival(String citaId) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.registerArrival(citaId);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<VehicleProgressDetail>> markInProcess(String citaId) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.markInProcess(citaId);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<VehicleProgressDetail>> markReturned(String citaId) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.markReturned(citaId);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<ProgressLog>>> getProgressHistory(String citaId) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.getProgressHistory(citaId);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> addManualProgress({
    required String citaId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      await remoteDataSource.addManualProgress(
        citaId: citaId,
        type: type,
        status: status,
        message: message,
        percentage: percentage,
      );
      return const Success(null);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }
}
