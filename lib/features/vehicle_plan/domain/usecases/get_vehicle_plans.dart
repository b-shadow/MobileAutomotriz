import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/repositories/vehicle_plan_repository.dart';

class GetVehiclePlans implements UseCase<List<VehiclePlan>, NoParams> {
  final VehiclePlanRepository repository;

  const GetVehiclePlans(this.repository);

  @override
  Future<Result<List<VehiclePlan>>> call(NoParams params) async {
    return repository.getPlans();
  }
}

