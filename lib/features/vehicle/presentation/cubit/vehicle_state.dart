import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';

abstract class VehicleState {
  const VehicleState();
}

class VehicleInitial extends VehicleState {
  const VehicleInitial();
}

class VehicleLoading extends VehicleState {
  const VehicleLoading();
}

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  const VehicleLoaded({required this.vehicles});
}

class VehicleOperationSuccess extends VehicleState {
  final String message;
  final List<Vehicle> vehicles;

  const VehicleOperationSuccess({
    required this.message,
    required this.vehicles,
  });
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError({required this.message});
}

