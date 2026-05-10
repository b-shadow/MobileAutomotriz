import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/domain/repositories/appointment_repository.dart';

class CreateAppointmentParams extends Equatable {
  final Map<String, dynamic> data;
  const CreateAppointmentParams({required this.data});

  @override
  List<Object?> get props => [data];
}

class CreateAppointment implements UseCase<Appointment, CreateAppointmentParams> {
  final AppointmentRepository repository;

  CreateAppointment(this.repository);

  @override
  Future<Result<Appointment>> call(CreateAppointmentParams params) {
    return repository.createAppointment(params.data);
  }
}
