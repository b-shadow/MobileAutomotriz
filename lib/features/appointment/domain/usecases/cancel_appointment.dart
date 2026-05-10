import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/domain/repositories/appointment_repository.dart';

class CancelAppointmentParams extends Equatable {
  final String id;
  final String motivo;
  const CancelAppointmentParams({required this.id, required this.motivo});

  @override
  List<Object?> get props => [id, motivo];
}

class CancelAppointment implements UseCase<Appointment, CancelAppointmentParams> {
  final AppointmentRepository repository;

  CancelAppointment(this.repository);

  @override
  Future<Result<Appointment>> call(CancelAppointmentParams params) {
    return repository.cancelAppointment(id: params.id, motivo: params.motivo);
  }
}
