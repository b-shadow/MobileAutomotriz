import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/vehicle/data/datasources/vehicle_remote_data_source.dart';
import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';
import 'package:mobile1_app/features/vehicle/domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const VehicleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<Vehicle>>> getVehicles() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final vehicles = await remoteDataSource.getVehicles();
      return Success(vehicles);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Vehicle>> createVehicle(Map<String, dynamic> data) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final vehicle = await remoteDataSource.createVehicle(data);
      return Success(vehicle);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Vehicle>> updateVehicle({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final vehicle = await remoteDataSource.updateVehicle(id: id, data: data);
      return Success(vehicle);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<Vehicle>> updateVehicleStatus({
    required String id,
    required String estado,
    String? motivo,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final vehicle = await remoteDataSource.updateVehicleStatus(
        id: id,
        estado: estado,
        motivo: motivo,
      );
      return Success(vehicle);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}

