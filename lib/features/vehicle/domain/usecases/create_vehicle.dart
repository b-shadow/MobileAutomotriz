import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';
import 'package:mobile1_app/features/vehicle/domain/repositories/vehicle_repository.dart';

class CreateVehicle implements UseCase<Vehicle, CreateVehicleParams> {
  final VehicleRepository repository;

  const CreateVehicle(this.repository);

  @override
  Future<Result<Vehicle>> call(CreateVehicleParams params) async {
    return repository.createVehicle(params.data);
  }
}

class CreateVehicleParams extends Equatable {
  final Map<String, dynamic> data;

  const CreateVehicleParams({required this.data});

  @override
  List<Object?> get props => [data];
}

