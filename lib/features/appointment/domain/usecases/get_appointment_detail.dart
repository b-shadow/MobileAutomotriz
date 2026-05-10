import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/domain/repositories/appointment_repository.dart';

class GetAppointmentDetailParams extends Equatable {
  final String id;
  const GetAppointmentDetailParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class GetAppointmentDetail implements UseCase<Appointment, GetAppointmentDetailParams> {
  final AppointmentRepository repository;

  GetAppointmentDetail(this.repository);

  @override
  Future<Result<Appointment>> call(GetAppointmentDetailParams params) {
    return repository.getAppointmentDetail(params.id);
  }
}
