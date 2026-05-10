import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/domain/repositories/appointment_repository.dart';

class GetAppointments implements UseCase<List<Appointment>, NoParams> {
  final AppointmentRepository repository;

  GetAppointments(this.repository);

  @override
  Future<Result<List<Appointment>>> call(NoParams params) {
    return repository.getAppointments();
  }
}
