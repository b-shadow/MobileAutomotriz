import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/domain/repositories/appointment_repository.dart';

class RescheduleAppointmentParams extends Equatable {
  final String id;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final String motivoReprogramacion;

  const RescheduleAppointmentParams({
    required this.id,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.motivoReprogramacion,
  });

  @override
  List<Object?> get props => [id, fechaHoraInicio, fechaHoraFin, motivoReprogramacion];
}

class RescheduleAppointment
    implements UseCase<Appointment, RescheduleAppointmentParams> {
  final AppointmentRepository repository;

  RescheduleAppointment(this.repository);

  @override
  Future<Result<Appointment>> call(RescheduleAppointmentParams params) {
    return repository.rescheduleAppointment(
      id: params.id,
      fechaHoraInicio: params.fechaHoraInicio,
      fechaHoraFin: params.fechaHoraFin,
      motivoReprogramacion: params.motivoReprogramacion,
    );
  }
}
