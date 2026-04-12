import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/repositories/vehicle_plan_repository.dart';

class UpdateVehiclePlanStatus
    implements UseCase<VehiclePlan, UpdateVehiclePlanStatusParams> {
  final VehiclePlanRepository repository;

  const UpdateVehiclePlanStatus(this.repository);

  @override
  Future<Result<VehiclePlan>> call(UpdateVehiclePlanStatusParams params) async {
    return repository.updatePlanStatus(
      planId: params.planId,
      estado: params.estado,
      motivo: params.motivo,
    );
  }
}

class UpdateVehiclePlanStatusParams extends Equatable {
  final String planId;
  final String estado;
  final String? motivo;

  const UpdateVehiclePlanStatusParams({required this.planId, required this.estado, this.motivo});

  @override
  List<Object?> get props => [planId, estado, motivo];
}

