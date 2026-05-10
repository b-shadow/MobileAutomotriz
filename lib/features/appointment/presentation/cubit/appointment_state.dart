import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';

sealed class AppointmentState extends Equatable {
  /// Citas filtradas (las que se muestran en pantalla).
  final List<Appointment> appointments;
  /// Todas las citas sin filtrar.
  final List<Appointment> allAppointments;

  const AppointmentState({
    this.appointments = const [],
    this.allAppointments = const [],
  });

  @override
  List<Object?> get props => [appointments, allAppointments];
}

final class AppointmentInitial extends AppointmentState {
  const AppointmentInitial()
      : super(appointments: const [], allAppointments: const []);
}

final class AppointmentLoading extends AppointmentState {
  const AppointmentLoading({
    super.appointments,
    super.allAppointments,
  });
}

final class AppointmentLoaded extends AppointmentState {
  final Appointment? selectedAppointment;
  final String? estadoFiltro;

  const AppointmentLoaded({
    required super.appointments,
    super.allAppointments,
    this.selectedAppointment,
    this.estadoFiltro,
  });

  @override
  List<Object?> get props =>
      [appointments, allAppointments, selectedAppointment, estadoFiltro];
}

final class AppointmentSuccess extends AppointmentState {
  final String message;
  final Appointment? selectedAppointment;
  final String? estadoFiltro;

  const AppointmentSuccess({
    required super.appointments,
    super.allAppointments,
    required this.message,
    this.selectedAppointment,
    this.estadoFiltro,
  });

  @override
  List<Object?> get props =>
      [appointments, allAppointments, message, selectedAppointment, estadoFiltro];
}

final class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError({
    required super.appointments,
    super.allAppointments,
    required this.message,
  });

  @override
  List<Object?> get props => [appointments, allAppointments, message];
}
