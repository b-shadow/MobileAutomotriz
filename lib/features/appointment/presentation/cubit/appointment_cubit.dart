import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/appointment/domain/entities/appointment.dart';
import 'package:mobile1_app/features/appointment/domain/usecases/cancel_appointment.dart';
import 'package:mobile1_app/features/appointment/domain/usecases/create_appointment.dart';
import 'package:mobile1_app/features/appointment/domain/usecases/get_appointment_detail.dart';
import 'package:mobile1_app/features/appointment/domain/usecases/get_appointments.dart';
import 'package:mobile1_app/features/appointment/domain/usecases/mark_no_show_appointment.dart';
import 'package:mobile1_app/features/appointment/domain/usecases/reschedule_appointment.dart';

import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final GetAppointments _getAppointments;
  final GetAppointmentDetail _getAppointmentDetail;
  final CreateAppointment _createAppointment;
  final CancelAppointment _cancelAppointment;
  final RescheduleAppointment _rescheduleAppointment;
  final MarkNoShowAppointment _markNoShow;

  List<Appointment> _appointments = const [];
  Appointment? _selectedAppointment;
  String? _estadoFiltro;

  AppointmentCubit({
    required GetAppointments getAppointments,
    required GetAppointmentDetail getAppointmentDetail,
    required CreateAppointment createAppointment,
    required CancelAppointment cancelAppointment,
    required RescheduleAppointment rescheduleAppointment,
    required MarkNoShowAppointment markNoShow,
  })  : _getAppointments = getAppointments,
        _getAppointmentDetail = getAppointmentDetail,
        _createAppointment = createAppointment,
        _cancelAppointment = cancelAppointment,
        _rescheduleAppointment = rescheduleAppointment,
        _markNoShow = markNoShow,
        super(const AppointmentInitial());

  /// Carga todas las citas del tenant. Respeta el filtro de estado activo.
  Future<void> fetchAppointments() async {
    emit(AppointmentLoading(appointments: _appointments));
    final result = await _getAppointments(const NoParams());
    switch (result) {
      case Success(:final data):
        _appointments = data;
        emit(AppointmentLoaded(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
      case Err(:final failure):
        emit(AppointmentError(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: failure.message,
        ));
    }
  }

  /// Filtra las citas por estado. Pasar null para mostrar todas.
  void filtrarPorEstado(String? estado) {
    _estadoFiltro = estado;
    emit(AppointmentLoaded(
      appointments: _filteredAppointments,
      allAppointments: _appointments,
      selectedAppointment: _selectedAppointment,
      estadoFiltro: _estadoFiltro,
    ));
  }

  List<Appointment> get _filteredAppointments {
    if (_estadoFiltro == null || _estadoFiltro!.isEmpty) return _appointments;
    return _appointments.where((a) => a.estado == _estadoFiltro).toList();
  }

  /// Carga el detalle de una cita específica.
  Future<void> fetchDetail(String id) async {
    emit(AppointmentLoading(appointments: _filteredAppointments));
    final result = await _getAppointmentDetail(GetAppointmentDetailParams(id: id));
    switch (result) {
      case Success(:final data):
        _selectedAppointment = data;
        emit(AppointmentLoaded(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
      case Err(:final failure):
        emit(AppointmentError(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: failure.message,
        ));
    }
  }

  /// Crea una nueva cita.
  Future<void> createAppointment(Map<String, dynamic> data) async {
    emit(AppointmentLoading(appointments: _filteredAppointments));
    final result = await _createAppointment(CreateAppointmentParams(data: data));
    switch (result) {
      case Success(:final data):
        _selectedAppointment = data;
        await fetchAppointments();
        emit(AppointmentSuccess(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: 'Cita creada exitosamente.',
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
        emit(AppointmentLoaded(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
      case Err(:final failure):
        emit(AppointmentError(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: failure.message,
        ));
    }
  }

  /// Cancela una cita existente.
  Future<void> cancelAppointment({
    required String id,
    required String motivo,
  }) async {
    emit(AppointmentLoading(appointments: _filteredAppointments));
    final result =
        await _cancelAppointment(CancelAppointmentParams(id: id, motivo: motivo));
    switch (result) {
      case Success(:final data):
        _selectedAppointment = data;
        _appointments = _appointments.map((a) => a.id == id ? data : a).toList();
        emit(AppointmentSuccess(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: 'Cita cancelada exitosamente.',
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
        emit(AppointmentLoaded(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
      case Err(:final failure):
        emit(AppointmentError(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: failure.message,
        ));
    }
  }

  /// Reprograma una cita a una nueva fecha/hora.
  Future<void> rescheduleAppointment({
    required String id,
    required DateTime fechaHoraInicio,
    required DateTime fechaHoraFin,
    required String motivo,
  }) async {
    emit(AppointmentLoading(appointments: _filteredAppointments));
    final result = await _rescheduleAppointment(RescheduleAppointmentParams(
      id: id,
      fechaHoraInicio: fechaHoraInicio,
      fechaHoraFin: fechaHoraFin,
      motivoReprogramacion: motivo,
    ));
    switch (result) {
      case Success(:final data):
        _selectedAppointment = data;
        // La cita original queda como REPROGRAMADA; recargamos la lista
        await fetchAppointments();
        emit(AppointmentSuccess(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: 'Cita reprogramada exitosamente.',
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
        emit(AppointmentLoaded(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
      case Err(:final failure):
        emit(AppointmentError(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: failure.message,
        ));
    }
  }

  /// Marca una cita como no-show (inasistencia).
  Future<void> markNoShow({
    required String id,
    String? observacion,
  }) async {
    emit(AppointmentLoading(appointments: _filteredAppointments));
    final result = await _markNoShow(MarkNoShowParams(id: id, observacion: observacion));
    switch (result) {
      case Success(:final data):
        _selectedAppointment = data;
        _appointments = _appointments.map((a) => a.id == id ? data : a).toList();
        emit(AppointmentSuccess(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: 'Inasistencia registrada. La cita fue marcada como No-Show.',
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
        emit(AppointmentLoaded(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          selectedAppointment: _selectedAppointment,
          estadoFiltro: _estadoFiltro,
        ));
      case Err(:final failure):
        emit(AppointmentError(
          appointments: _filteredAppointments,
          allAppointments: _appointments,
          message: failure.message,
        ));
    }
  }

  /// Limpia la selección actual.
  void clearSelection() {
    _selectedAppointment = null;
    emit(AppointmentLoaded(
      appointments: _filteredAppointments,
      allAppointments: _appointments,
      estadoFiltro: _estadoFiltro,
    ));
  }
}
