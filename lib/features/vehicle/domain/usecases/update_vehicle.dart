import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';
import 'package:mobile1_app/features/vehicle/domain/repositories/vehicle_repository.dart';

class UpdateVehicle implements UseCase<Vehicle, UpdateVehicleParams> {
  final VehicleRepository repository;

  const UpdateVehicle(this.repository);

  @override
  Future<Result<Vehicle>> call(UpdateVehicleParams params) async {
    return repository.updateVehicle(id: params.id, data: params.data);
  }
}

class UpdateVehicleParams extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const UpdateVehicleParams({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

