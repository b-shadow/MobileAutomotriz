import '../../../../core/error/result.dart';
import '../../../workshop_progress/domain/entities/progress_log.dart';
import '../entities/vehicle_progress.dart';
import '../entities/vehicle_progress_detail.dart';

abstract class VehicleProgressRepository {
  Future<Result<List<VehicleProgress>>> getOperativeAppointments();
  Future<Result<VehicleProgressDetail>> getVehicleProgressDetail(String citaId);
  Future<Result<VehicleProgressDetail>> registerArrival(String citaId);
  Future<Result<VehicleProgressDetail>> markInProcess(String citaId);
  Future<Result<VehicleProgressDetail>> markReturned(String citaId);
  Future<Result<List<ProgressLog>>> getProgressHistory(String citaId);
  Future<Result<void>> addManualProgress({
    required String citaId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  });
}
