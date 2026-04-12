import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';
import 'package:mobile1_app/features/vehicle/domain/repositories/vehicle_repository.dart';

class UpdateVehicleStatus
    implements UseCase<Vehicle, UpdateVehicleStatusParams> {
  final VehicleRepository repository;

  const UpdateVehicleStatus(this.repository);

  @override
  Future<Result<Vehicle>> call(UpdateVehicleStatusParams params) async {
    return repository.updateVehicleStatus(
      id: params.id,
      estado: params.estado,
      motivo: params.motivo,
    );
  }
}

class UpdateVehicleStatusParams extends Equatable {
  final String id;
  final String estado;
  final String? motivo;

  const UpdateVehicleStatusParams({
    required this.id,
    required this.estado,
    this.motivo,
  });

  @override
  List<Object?> get props => [id, estado, motivo];
}

