import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';
import 'package:mobile1_app/features/workshop_progress/domain/usecases/workshop_progress_usecases.dart';
import 'workshop_progress_state.dart';

class WorkshopProgressCubit extends Cubit<WorkshopProgressState> {
  final GetActiveWorkOrders _getActiveWorkOrders;
  final GetProgressWorkOrderDetail _getWorkOrderDetail;
  final GetProgressHistory _getProgressHistory;
  final StartService _startService;
  final PauseService _pauseService;
  final FinishService _finishService;
  final MarkServiceUnnecessary _markServiceUnnecessary;
  final FinishWorkOrder _finishWorkOrder;
  final AddManualProgress _addManualProgress;

  List<WorkOrder> _activeOrders = const [];
  List<ProgressLog> _history = const [];
  WorkOrder? _currentDetail;

  WorkshopProgressCubit({
    required GetActiveWorkOrders getActiveWorkOrders,
    required GetProgressWorkOrderDetail getWorkOrderDetail,
    required GetProgressHistory getProgressHistory,
    required StartService startService,
    required PauseService pauseService,
    required FinishService finishService,
    required MarkServiceUnnecessary markServiceUnnecessary,
    required FinishWorkOrder finishWorkOrder,
    required AddManualProgress addManualProgress,
  })  : _getActiveWorkOrders = getActiveWorkOrders,
        _getWorkOrderDetail = getWorkOrderDetail,
        _getProgressHistory = getProgressHistory,
        _startService = startService,
        _pauseService = pauseService,
        _finishService = finishService,
        _markServiceUnnecessary = markServiceUnnecessary,
        _finishWorkOrder = finishWorkOrder,
        _addManualProgress = addManualProgress,
        super(const WorkshopProgressInitial());

  Future<void> fetchActiveWorkOrders() async {
    emit(WorkshopProgressLoading(activeOrders: _activeOrders, history: _history));
    final result = await _getActiveWorkOrders(const NoParams());
    switch (result) {
      case Success(:final data):
        _activeOrders = data;
        emit(WorkshopProgressLoaded(activeOrders: _activeOrders, history: _history));
      case Err(:final failure):
        emit(WorkshopProgressError(activeOrders: _activeOrders, history: _history, message: failure.message));
    }
  }

  Future<void> fetchWorkOrderDetail(String id) async {
    emit(WorkshopProgressLoading(activeOrders: _activeOrders, history: _history));
    final result = await _getWorkOrderDetail(id);
    switch (result) {
      case Success(:final data):
        _currentDetail = data;
        emit(WorkshopProgressDetailLoaded(activeOrders: _activeOrders, history: _history, detail: _currentDetail!));
      case Err(:final failure):
        emit(WorkshopProgressError(activeOrders: _activeOrders, history: _history, message: failure.message));
    }
  }

  Future<void> fetchProgressHistory(String orderId) async {
    emit(WorkshopProgressLoading(activeOrders: _activeOrders, history: _history));
    final result = await _getProgressHistory(orderId);
    switch (result) {
      case Success(:final data):
        _history = data;
        if (_currentDetail != null) {
          emit(WorkshopProgressHistoryLoaded(activeOrders: _activeOrders, history: _history, detail: _currentDetail!));
        } else {
          emit(WorkshopProgressLoaded(activeOrders: _activeOrders, history: _history));
        }
      case Err(:final failure):
        emit(WorkshopProgressError(activeOrders: _activeOrders, history: _history, message: failure.message));
    }
  }

  Future<void> startServiceDetail(String orderId, String detailId) async {
    emit(WorkshopProgressLoading(activeOrders: _activeOrders, history: _history));
    final result = await _startService(orderId, detailId);
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(orderId);
        emit(WorkshopProgressSuccess(activeOrders: _activeOrders, history: _history, message: 'Servicio iniciado.', detail: _currentDetail));
      case Err(:final failure):
        emit(WorkshopProgressError(activeOrders: _activeOrders, history: _history, message: failure.message));
    }
  }

  Future<void> pauseServiceDetail(String orderId, String detailId, String reason) async {
    emit(WorkshopProgressLoading(activeOrders: _activeOrders, history: _history));
    final result = await _pauseService(orderId: orderId, detailId: detailId, reason: reason);
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(orderId);
        emit(WorkshopProgressSuccess(activeOrders: _activeOrders, history: _history, message: 'Servicio pausado.', detail: _currentDetail));
      case Err(:final failure):
        emit(WorkshopProgressError(activeOrders: _activeOrders, history: _history, message: failure.message));
    }
  }

  Future<void> finishServiceDetail(String orderId, String detailId, int realTime, String obs) async {
    emit(WorkshopProgressLoading(activeOrders: _activeOrders, history: _history));
    final result = await _finishService(orderId: orderId, detailId: detailId, realTimeMinutes: realTime, observations: obs);
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(orderId);
        emit(WorkshopProgressSuccess(activeOrders: _activeOrders, history: _history, message: 'Servicio finalizado.', detail: _currentDetail));
      case Err(:final failure):
        emit(WorkshopProgressError(activeOrders: _activeOrders, history: _history, message: failure.message));
    }
  }

  Future<void> markServiceUnnecessary(String orderId, String detailId, String reason) async {
    emit(WorkshopProgressLoading(activeOrders: _activeOrders, history: _history));
    final result = await _markServiceUnnecessary(orderId: orderId, detailId: detailId, reason: reason);
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(orderId);
        emit(WorkshopProgressSuccess(activeOrders: _activeOrders, history: _history, message: 'Servicio marcado como innecesario.', detail: _currentDetail));
      case Err(:final failure):
        emit(WorkshopProgressError(activeOrders: _activeOrders, history: _history, message: failure.message));
    }
  }

  Future<void> finishWorkOrder(String orderId) async {
    emit(WorkshopProgressLoading(activeOrders: _activeOrders, history: _history));
    final result = await _finishWorkOrder(orderId);
    switch (result) {
      case Success(:final data):
        _currentDetail = data;
        emit(WorkshopProgressSuccess(activeOrders: _activeOrders, history: _history, message: 'Orden de trabajo finalizada.', detail: _currentDetail));
      case Err(:final failure):
        emit(WorkshopProgressError(activeOrders: _activeOrders, history: _history, message: failure.message));
    }
  }

  Future<void> addManualProgressLog({
    required String citaId,
    required String orderId,
    required String message,
    int? percentage,
  }) async {
    emit(WorkshopProgressLoading(activeOrders: _activeOrders, history: _history));
    final result = await _addManualProgress(
      citaId: citaId,
      type: 'GENERAL',
      status: 'ACTUALIZACION',
      message: message,
      percentage: percentage,
    );
    switch (result) {
      case Success():
        await fetchProgressHistory(orderId);
        emit(WorkshopProgressSuccess(activeOrders: _activeOrders, history: _history, message: 'Progreso registrado con éxito.', detail: _currentDetail));
      case Err(:final failure):
        emit(WorkshopProgressError(activeOrders: _activeOrders, history: _history, message: failure.message));
    }
  }
}
