import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';

abstract class VehiclePlanRepository {
  Future<Result<List<VehiclePlan>>> getPlans();
  Future<Result<VehiclePlan>> getPlanDetail(String planId);
  Future<Result<VehiclePlan>> updatePlan({required String planId, required Map<String, dynamic> data});
  Future<Result<VehiclePlan>> updatePlanStatus({required String planId, required String estado, String? motivo});
  Future<Result<List<VehiclePlanDetail>>> getPlanDetails(String planId);
  Future<Result<VehiclePlanDetail>> createPlanDetail({required String planId, required Map<String, dynamic> data});
  Future<Result<VehiclePlanDetail>> updatePlanDetail({required String detailId, required Map<String, dynamic> data});
  Future<Result<VehiclePlanDetail>> updatePlanDetailStatus({required String detailId, required String estado, String? motivo});
}

