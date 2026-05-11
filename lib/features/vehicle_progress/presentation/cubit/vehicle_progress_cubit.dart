import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/result.dart';
import '../../../workshop_progress/domain/entities/progress_log.dart';
import '../../domain/entities/vehicle_progress.dart';
import '../../domain/entities/vehicle_progress_detail.dart';
import '../../domain/usecases/vehicle_progress_usecases.dart';

abstract class VehicleProgressState {}

class VehicleProgressInitial extends VehicleProgressState {}

class VehicleProgressLoading extends VehicleProgressState {
  final List<VehicleProgress> appointments;
  final List<ProgressLog> history;
  VehicleProgressLoading({this.appointments = const [], this.history = const []});
}

class VehicleProgressLoaded extends VehicleProgressState {
  final List<VehicleProgress> appointments;
  VehicleProgressLoaded({required this.appointments});
}

class VehicleProgressDetailLoaded extends VehicleProgressState {
  final List<VehicleProgress> appointments;
  final VehicleProgressDetail detail;
  final List<ProgressLog> history;
  VehicleProgressDetailLoaded({
    required this.appointments,
    required this.detail,
    required this.history,
  });
}

class VehicleProgressError extends VehicleProgressState {
  final String message;
  final List<VehicleProgress> appointments;
  final List<ProgressLog> history;
  VehicleProgressError({
    required this.message,
    this.appointments = const [],
    this.history = const [],
  });
}

class VehicleProgressSuccess extends VehicleProgressState {
  final String message;
  final List<VehicleProgress> appointments;
  final VehicleProgressDetail? detail;
  final List<ProgressLog> history;
  VehicleProgressSuccess({
    required this.message,
    this.appointments = const [],
    this.detail,
    this.history = const [],
  });
}

class VehicleProgressCubit extends Cubit<VehicleProgressState> {
  final GetOperativeAppointments _getAppointments;
  final GetVehicleProgressDetail _getDetail;
  final RegisterVehicleArrival _registerArrival;
  final MarkVehicleInProcess _markInProcess;
  final MarkVehicleReturned _markReturned;
  final GetVehicleProgressHistory _getHistory;
  final AddManualGeneralProgress _addManualProgress;

  List<VehicleProgress> _appointments = [];
  VehicleProgressDetail? _currentDetail;
  List<ProgressLog> _history = [];

  VehicleProgressCubit({
    required GetOperativeAppointments getAppointments,
    required GetVehicleProgressDetail getDetail,
    required RegisterVehicleArrival registerArrival,
    required MarkVehicleInProcess markInProcess,
    required MarkVehicleReturned markReturned,
    required GetVehicleProgressHistory getHistory,
    required AddManualGeneralProgress addManualProgress,
  })  : _getAppointments = getAppointments,
        _getDetail = getDetail,
        _registerArrival = registerArrival,
        _markInProcess = markInProcess,
        _markReturned = markReturned,
        _getHistory = getHistory,
        _addManualProgress = addManualProgress,
        super(VehicleProgressInitial());

  Future<void> fetchAppointments() async {
    emit(VehicleProgressLoading(appointments: _appointments, history: _history));
    final result = await _getAppointments();
    switch (result) {
      case Success(:final data):
        _appointments = data;
        emit(VehicleProgressLoaded(appointments: _appointments));
      case Err(:final failure):
        emit(VehicleProgressError(appointments: _appointments, history: _history, message: failure.message));
    }
  }

  Future<void> fetchDetail(String citaId) async {
    emit(VehicleProgressLoading(appointments: _appointments, history: _history));
    final resultDetail = await _getDetail(citaId);
    switch (resultDetail) {
      case Success(:final data):
        _currentDetail = data;
        await _fetchHistorySilent(citaId);
        emit(VehicleProgressDetailLoaded(appointments: _appointments, detail: _currentDetail!, history: _history));
      case Err(:final failure):
        emit(VehicleProgressError(appointments: _appointments, history: _history, message: failure.message));
    }
  }

  Future<void> _fetchHistorySilent(String citaId) async {
    final resultHistory = await _getHistory(citaId);
    if (resultHistory is Success) {
      _history = (resultHistory as Success<List<ProgressLog>>).data;
    }
  }

  Future<void> registerArrival(String citaId) async {
    emit(VehicleProgressLoading(appointments: _appointments, history: _history));
    final result = await _registerArrival(citaId);
    switch (result) {
      case Success(:final data):
        _currentDetail = data;
        await _fetchHistorySilent(citaId);
        emit(VehicleProgressSuccess(appointments: _appointments, detail: _currentDetail, history: _history, message: 'Llegada registrada exitosamente.'));
        emit(VehicleProgressDetailLoaded(appointments: _appointments, detail: _currentDetail!, history: _history));
      case Err(:final failure):
        emit(VehicleProgressError(appointments: _appointments, history: _history, message: failure.message));
        if (_currentDetail != null) {
          emit(VehicleProgressDetailLoaded(appointments: _appointments, detail: _currentDetail!, history: _history));
        }
    }
  }

  Future<void> markInProcess(String citaId) async {
    emit(VehicleProgressLoading(appointments: _appointments, history: _history));
    final result = await _markInProcess(citaId);
    switch (result) {
      case Success(:final data):
        _currentDetail = data;
        await _fetchHistorySilent(citaId);
        emit(VehicleProgressSuccess(appointments: _appointments, detail: _currentDetail, history: _history, message: 'Vehículo en proceso de atención.'));
        emit(VehicleProgressDetailLoaded(appointments: _appointments, detail: _currentDetail!, history: _history));
      case Err(:final failure):
        emit(VehicleProgressError(appointments: _appointments, history: _history, message: failure.message));
        if (_currentDetail != null) {
          emit(VehicleProgressDetailLoaded(appointments: _appointments, detail: _currentDetail!, history: _history));
        }
    }
  }

  Future<void> markReturned(String citaId) async {
    emit(VehicleProgressLoading(appointments: _appointments, history: _history));
    final result = await _markReturned(citaId);
    switch (result) {
      case Success(:final data):
        _currentDetail = data;
        await _fetchHistorySilent(citaId);
        emit(VehicleProgressSuccess(appointments: _appointments, detail: _currentDetail, history: _history, message: 'Vehículo devuelto al cliente.'));
        emit(VehicleProgressDetailLoaded(appointments: _appointments, detail: _currentDetail!, history: _history));
      case Err(:final failure):
        emit(VehicleProgressError(appointments: _appointments, history: _history, message: failure.message));
        if (_currentDetail != null) {
          emit(VehicleProgressDetailLoaded(appointments: _appointments, detail: _currentDetail!, history: _history));
        }
    }
  }

  Future<void> addManualProgressLog({
    required String citaId,
    required String message,
  }) async {
    emit(VehicleProgressLoading(appointments: _appointments, history: _history));
    final result = await _addManualProgress(
      citaId: citaId,
      type: 'GENERAL',
      status: 'ACTUALIZACION',
      message: message,
    );
    switch (result) {
      case Success():
        await _fetchHistorySilent(citaId);
        emit(VehicleProgressSuccess(appointments: _appointments, detail: _currentDetail, history: _history, message: 'Nota registrada con éxito.'));
        if (_currentDetail != null) {
          emit(VehicleProgressDetailLoaded(appointments: _appointments, detail: _currentDetail!, history: _history));
        }
      case Err(:final failure):
        emit(VehicleProgressError(appointments: _appointments, history: _history, message: failure.message));
        if (_currentDetail != null) {
          emit(VehicleProgressDetailLoaded(appointments: _appointments, detail: _currentDetail!, history: _history));
        }
    }
  }
}
