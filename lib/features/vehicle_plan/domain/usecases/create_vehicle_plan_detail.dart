import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/repositories/vehicle_plan_repository.dart';

class CreateVehiclePlanDetail
    implements UseCase<VehiclePlanDetail, CreateVehiclePlanDetailParams> {
  final VehiclePlanRepository repository;

  const CreateVehiclePlanDetail(this.repository);

  @override
  Future<Result<VehiclePlanDetail>> call(CreateVehiclePlanDetailParams params) async {
    return repository.createPlanDetail(planId: params.planId, data: params.data);
  }
}

class CreateVehiclePlanDetailParams extends Equatable {
  final String planId;
  final Map<String, dynamic> data;

  const CreateVehiclePlanDetailParams({required this.planId, required this.data});

  @override
  List<Object?> get props => [planId, data];
}

