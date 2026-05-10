import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Result<List<Appointment>>> getAppointments();
  Future<Result<Appointment>> getAppointmentDetail(String id);
  Future<Result<Appointment>> createAppointment(Map<String, dynamic> data);
  Future<Result<Appointment>> cancelAppointment({
    required String id,
    required String motivo,
  });
  Future<Result<Appointment>> rescheduleAppointment({
    required String id,
    required DateTime fechaHoraInicio,
    required DateTime fechaHoraFin,
    required String motivoReprogramacion,
  });
  Future<Result<Appointment>> markNoShow({
    required String id,
    String? observacion,
  });
}
