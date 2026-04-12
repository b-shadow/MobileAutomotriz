import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/repositories/vehicle_plan_repository.dart';

class GetVehiclePlanDetails
    implements UseCase<List<VehiclePlanDetail>, GetVehiclePlanDetailsParams> {
  final VehiclePlanRepository repository;

  const GetVehiclePlanDetails(this.repository);

  @override
  Future<Result<List<VehiclePlanDetail>>> call(GetVehiclePlanDetailsParams params) async {
    return repository.getPlanDetails(params.planId);
  }
}

class GetVehiclePlanDetailsParams extends Equatable {
  final String planId;

  const GetVehiclePlanDetailsParams({required this.planId});

  @override
  List<Object?> get props => [planId];
}

