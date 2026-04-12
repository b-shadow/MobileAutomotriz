import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/repositories/vehicle_plan_repository.dart';

class UpdateVehiclePlanDetail
    implements UseCase<VehiclePlanDetail, UpdateVehiclePlanDetailParams> {
  final VehiclePlanRepository repository;

  const UpdateVehiclePlanDetail(this.repository);

  @override
  Future<Result<VehiclePlanDetail>> call(UpdateVehiclePlanDetailParams params) async {
    return repository.updatePlanDetail(detailId: params.detailId, data: params.data);
  }
}

class UpdateVehiclePlanDetailParams extends Equatable {
  final String detailId;
  final Map<String, dynamic> data;

  const UpdateVehiclePlanDetailParams({required this.detailId, required this.data});

  @override
  List<Object?> get props => [detailId, data];
}

