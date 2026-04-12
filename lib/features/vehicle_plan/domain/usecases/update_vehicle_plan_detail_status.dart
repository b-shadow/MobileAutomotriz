import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/repositories/vehicle_plan_repository.dart';

class UpdateVehiclePlanDetailStatus
    implements UseCase<VehiclePlanDetail, UpdateVehiclePlanDetailStatusParams> {
  final VehiclePlanRepository repository;

  const UpdateVehiclePlanDetailStatus(this.repository);

  @override
  Future<Result<VehiclePlanDetail>> call(UpdateVehiclePlanDetailStatusParams params) async {
    return repository.updatePlanDetailStatus(
      detailId: params.detailId,
      estado: params.estado,
      motivo: params.motivo,
    );
  }
}

class UpdateVehiclePlanDetailStatusParams extends Equatable {
  final String detailId;
  final String estado;
  final String? motivo;

  const UpdateVehiclePlanDetailStatusParams({required this.detailId, required this.estado, this.motivo});

  @override
  List<Object?> get props => [detailId, estado, motivo];
}

