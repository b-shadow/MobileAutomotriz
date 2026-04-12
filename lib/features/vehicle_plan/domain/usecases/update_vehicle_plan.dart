import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/repositories/vehicle_plan_repository.dart';

class UpdateVehiclePlan implements UseCase<VehiclePlan, UpdateVehiclePlanParams> {
  final VehiclePlanRepository repository;

  const UpdateVehiclePlan(this.repository);

  @override
  Future<Result<VehiclePlan>> call(UpdateVehiclePlanParams params) async {
    return repository.updatePlan(planId: params.planId, data: params.data);
  }
}

class UpdateVehiclePlanParams extends Equatable {
  final String planId;
  final Map<String, dynamic> data;

  const UpdateVehiclePlanParams({required this.planId, required this.data});

  @override
  List<Object?> get props => [planId, data];
}

