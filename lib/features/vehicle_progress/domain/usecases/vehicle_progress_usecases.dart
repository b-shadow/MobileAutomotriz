import '../../../../core/error/result.dart';
import '../../../workshop_progress/domain/entities/progress_log.dart';
import '../entities/vehicle_progress.dart';
import '../entities/vehicle_progress_detail.dart';
import '../repositories/vehicle_progress_repository.dart';

class GetOperativeAppointments {
  final VehicleProgressRepository repository;
  GetOperativeAppointments(this.repository);
  Future<Result<List<VehicleProgress>>> call() => repository.getOperativeAppointments();
}

class GetVehicleProgressDetail {
  final VehicleProgressRepository repository;
  GetVehicleProgressDetail(this.repository);
  Future<Result<VehicleProgressDetail>> call(String citaId) => repository.getVehicleProgressDetail(citaId);
}

class RegisterVehicleArrival {
  final VehicleProgressRepository repository;
  RegisterVehicleArrival(this.repository);
  Future<Result<VehicleProgressDetail>> call(String citaId) => repository.registerArrival(citaId);
}

class MarkVehicleInProcess {
  final VehicleProgressRepository repository;
  MarkVehicleInProcess(this.repository);
  Future<Result<VehicleProgressDetail>> call(String citaId) => repository.markInProcess(citaId);
}

class MarkVehicleReturned {
  final VehicleProgressRepository repository;
  MarkVehicleReturned(this.repository);
  Future<Result<VehicleProgressDetail>> call(String citaId) => repository.markReturned(citaId);
}

class GetVehicleProgressHistory {
  final VehicleProgressRepository repository;
  GetVehicleProgressHistory(this.repository);
  Future<Result<List<ProgressLog>>> call(String citaId) => repository.getProgressHistory(citaId);
}

class AddManualGeneralProgress {
  final VehicleProgressRepository repository;
  AddManualGeneralProgress(this.repository);
  Future<Result<void>> call({
    required String citaId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  }) => repository.addManualProgress(
    citaId: citaId,
    type: type,
    status: status,
    message: message,
    percentage: percentage,
  );
}
