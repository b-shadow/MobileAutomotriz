import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/domain/repositories/appointment_repository.dart';

class MarkNoShowParams extends Equatable {
  final String id;
  final String? observacion;

  const MarkNoShowParams({required this.id, this.observacion});

  @override
  List<Object?> get props => [id, observacion];
}

class MarkNoShowAppointment implements UseCase<Appointment, MarkNoShowParams> {
  final AppointmentRepository repository;

  MarkNoShowAppointment(this.repository);

  @override
  Future<Result<Appointment>> call(MarkNoShowParams params) {
    return repository.markNoShow(
      id: params.id,
      observacion: params.observacion,
    );
  }
}
