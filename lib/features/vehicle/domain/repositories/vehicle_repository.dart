import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';

abstract class VehicleRepository {
  Future<Result<List<Vehicle>>> getVehicles();

  Future<Result<Vehicle>> createVehicle(Map<String, dynamic> data);

  Future<Result<Vehicle>> updateVehicle({
    required String id,
    required Map<String, dynamic> data,
  });

  Future<Result<Vehicle>> updateVehicleStatus({
    required String id,
    required String estado,
    String? motivo,
  });
}

