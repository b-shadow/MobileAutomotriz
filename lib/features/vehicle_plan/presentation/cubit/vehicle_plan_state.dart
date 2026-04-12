import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan.dart';
import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';

abstract class VehiclePlanState {
  const VehiclePlanState();
}

class VehiclePlanInitial extends VehiclePlanState {
  const VehiclePlanInitial();
}

class VehiclePlanLoading extends VehiclePlanState {
  const VehiclePlanLoading();
}

class VehiclePlanLoaded extends VehiclePlanState {
  final List<VehiclePlan> plans;
  final List<VehiclePlanDetail> details;
  final String? selectedPlanId;

  const VehiclePlanLoaded({
    required this.plans,
    required this.details,
    required this.selectedPlanId,
  });
}

class VehiclePlanSuccess extends VehiclePlanState {
  final String message;
  final List<VehiclePlan> plans;
  final List<VehiclePlanDetail> details;
  final String? selectedPlanId;

  const VehiclePlanSuccess({
    required this.message,
    required this.plans,
    required this.details,
    required this.selectedPlanId,
  });
}

class VehiclePlanError extends VehiclePlanState {
  final String message;
  final List<VehiclePlan> plans;
  final List<VehiclePlanDetail> details;
  final String? selectedPlanId;

  const VehiclePlanError({
    required this.message,
    required this.plans,
    required this.details,
    required this.selectedPlanId,
  });
}

