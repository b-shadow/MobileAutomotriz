import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';
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
  // Repuestos
  final GetInventoryItems _getInventoryItems;
  final GetSparePartRequests _getSparePartRequests;
  final CreateSparePartRequest _createSparePartRequest;
  final MarkSparePartsReceived _markSparePartsReceived;

  List<WorkOrder> _activeOrders = const [];
  List<ProgressLog> _history = const [];
  WorkOrder? _currentDetail;
  List<InventoryItem> _inventoryItems = const [];
  List<SparePartRequest> _sparePartRequests = const [];

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
    required GetInventoryItems getInventoryItems,
    required GetSparePartRequests getSparePartRequests,
    required CreateSparePartRequest createSparePartRequest,
    required MarkSparePartsReceived markSparePartsReceived,
  })  : _getActiveWorkOrders = getActiveWorkOrders,
        _getWorkOrderDetail = getWorkOrderDetail,
        _getProgressHistory = getProgressHistory,
        _startService = startService,
        _pauseService = pauseService,
        _finishService = finishService,
        _markServiceUnnecessary = markServiceUnnecessary,
        _finishWorkOrder = finishWorkOrder,
        _addManualProgress = addManualProgress,
        _getInventoryItems = getInventoryItems,
        _getSparePartRequests = getSparePartRequests,
        _createSparePartRequest = createSparePartRequest,
        _markSparePartsReceived = markSparePartsReceived,
        super(const WorkshopProgressInitial());

  // ── Helpers ─────────────────────────────────────────────────────────────────

  WorkshopProgressState get _loading => WorkshopProgressLoading(
        activeOrders: _activeOrders,
        history: _history,
        inventoryItems: _inventoryItems,
        sparePartRequests: _sparePartRequests,
      );

  WorkshopProgressState _success(String msg) => WorkshopProgressSuccess(
        activeOrders: _activeOrders,
        history: _history,
        message: msg,
        detail: _currentDetail,
        inventoryItems: _inventoryItems,
        sparePartRequests: _sparePartRequests,
      );

  WorkshopProgressState _error(String msg) => WorkshopProgressError(
        activeOrders: _activeOrders,
        history: _history,
        message: msg,
        inventoryItems: _inventoryItems,
        sparePartRequests: _sparePartRequests,
      );

  // ── Órdenes activas ──────────────────────────────────────────────────────────

  Future<void> fetchActiveWorkOrders() async {
    emit(_loading);
    final result = await _getActiveWorkOrders(const NoParams());
    switch (result) {
      case Success(:final data):
        _activeOrders = data;
        emit(WorkshopProgressLoaded(
          activeOrders: _activeOrders,
          history: _history,
          inventoryItems: _inventoryItems,
          sparePartRequests: _sparePartRequests,
        ));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> fetchWorkOrderDetail(String id) async {
    emit(_loading);
    final result = await _getWorkOrderDetail(id);
    switch (result) {
      case Success(:final data):
        _currentDetail = data;
        // También cargamos las solicitudes de repuesto para esta orden
        await _loadSparePartRequests(id);
        emit(WorkshopProgressDetailLoaded(
          activeOrders: _activeOrders,
          history: _history,
          detail: _currentDetail!,
          inventoryItems: _inventoryItems,
          sparePartRequests: _sparePartRequests,
        ));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> fetchProgressHistory(String orderId) async {
    emit(_loading);
    final result = await _getProgressHistory(orderId);
    switch (result) {
      case Success(:final data):
        _history = data;
        if (_currentDetail != null) {
          emit(WorkshopProgressHistoryLoaded(
            activeOrders: _activeOrders,
            history: _history,
            detail: _currentDetail!,
            inventoryItems: _inventoryItems,
            sparePartRequests: _sparePartRequests,
          ));
        } else {
          emit(WorkshopProgressLoaded(
            activeOrders: _activeOrders,
            history: _history,
            inventoryItems: _inventoryItems,
            sparePartRequests: _sparePartRequests,
          ));
        }
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  // ── Acciones de detalle ──────────────────────────────────────────────────────

  Future<void> startServiceDetail(String orderId, String detailId) async {
    emit(_loading);
    final result = await _startService(orderId, detailId);
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(orderId);
        emit(_success('Servicio iniciado.'));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> pauseServiceDetail(String orderId, String detailId, String reason) async {
    emit(_loading);
    final result = await _pauseService(orderId: orderId, detailId: detailId, reason: reason);
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(orderId);
        emit(_success('Servicio pausado.'));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> finishServiceDetail(String orderId, String detailId, int realTime, String obs) async {
    emit(_loading);
    final result = await _finishService(orderId: orderId, detailId: detailId, realTimeMinutes: realTime, observations: obs);
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(orderId);
        emit(_success('Servicio finalizado.'));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> markServiceUnnecessary(String orderId, String detailId, String reason) async {
    emit(_loading);
    final result = await _markServiceUnnecessary(orderId: orderId, detailId: detailId, reason: reason);
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(orderId);
        emit(_success('Servicio marcado como innecesario.'));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> finishWorkOrder(String orderId) async {
    emit(_loading);
    final result = await _finishWorkOrder(orderId);
    switch (result) {
      case Success(:final data):
        _currentDetail = data;
        emit(_success('Orden de trabajo finalizada.'));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  Future<void> addManualProgressLog({
    required String citaId,
    required String orderId,
    required String message,
    int? percentage,
  }) async {
    emit(_loading);
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
        emit(_success('Progreso registrado con éxito.'));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  // ── Repuestos / Inventario ───────────────────────────────────────────────────

  /// Carga ítems de inventario activos (para el selector del modal).
  Future<void> loadInventoryItems() async {
    final result = await _getInventoryItems();
    if (result case Success(:final data)) {
      _inventoryItems = data;
      // Re-emit current state con inventario actualizado
      final current = state;
      if (current is WorkshopProgressDetailLoaded) {
        emit(WorkshopProgressDetailLoaded(
          activeOrders: _activeOrders,
          history: _history,
          detail: current.detail,
          inventoryItems: _inventoryItems,
          sparePartRequests: _sparePartRequests,
        ));
      }
    }
  }

  /// Carga solicitudes de repuesto para la orden actual (interno).
  Future<void> _loadSparePartRequests(String ordenGlobalId) async {
    final result = await _getSparePartRequests(ordenGlobalId: ordenGlobalId);
    if (result case Success(:final data)) {
      _sparePartRequests = data;
    }
  }

  /// Crea una solicitud de repuestos para una OT.
  Future<void> createSparePartRequest({
    required String citaId,
    required String ordenGlobalId,
    required String motivo,
    required List<SparePartRequestLine> lineas,
  }) async {
    emit(_loading);
    final result = await _createSparePartRequest(
      citaId: citaId,
      ordenGlobalId: ordenGlobalId,
      motivo: motivo,
      lineas: lineas,
    );
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(ordenGlobalId);
        emit(_success('Solicitud de repuestos creada.'));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }

  /// Marca un detalle de solicitud como recibido en el taller.
  Future<void> markSparePartReceived({
    required String solicitudId,
    required String detalleId,
    required int cantidadEntregada,
    required String ordenGlobalId,
  }) async {
    emit(_loading);
    final result = await _markSparePartsReceived(
      solicitudId: solicitudId,
      detalles: [
        {'detalle_id': detalleId, 'cantidad_recibida': cantidadEntregada},
      ],
    );
    switch (result) {
      case Success():
        await fetchWorkOrderDetail(ordenGlobalId);
        emit(_success('Repuesto marcado como recibido.'));
      case Err(:final failure):
        emit(_error(failure.message));
    }
  }
}
