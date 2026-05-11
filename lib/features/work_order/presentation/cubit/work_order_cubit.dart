import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/work_order/domain/usecases/work_order_usecases.dart';
import 'work_order_state.dart';

class WorkOrderCubit extends Cubit<WorkOrderState> {
  final GetWorkOrders _getWorkOrders;
  final GetWorkOrderDetail _getWorkOrderDetail;
  final GetAvailableMechanics _getAvailableMechanics;
  final AssignMechanics _assignMechanics;
  final AssignDetails _assignDetails;
  final StartWorkOrder _startWorkOrder;

  List<WorkOrder> _workOrders = const [];
  List<Mechanic> _mechanics = const [];

  WorkOrderCubit({
    required GetWorkOrders getWorkOrders,
    required GetWorkOrderDetail getWorkOrderDetail,
    required GetAvailableMechanics getAvailableMechanics,
    required AssignMechanics assignMechanics,
    required AssignDetails assignDetails,
    required StartWorkOrder startWorkOrder,
  })  : _getWorkOrders = getWorkOrders,
        _getWorkOrderDetail = getWorkOrderDetail,
        _getAvailableMechanics = getAvailableMechanics,
        _assignMechanics = assignMechanics,
        _assignDetails = assignDetails,
        _startWorkOrder = startWorkOrder,
        super(const WorkOrderInitial());

  Future<void> fetchWorkOrders() async {
    emit(WorkOrderLoading(workOrders: _workOrders, mechanics: _mechanics));
    final result = await _getWorkOrders(const NoParams());
    switch (result) {
      case Success(:final data):
        _workOrders = data;
        emit(WorkOrderLoaded(workOrders: _workOrders, mechanics: _mechanics));
      case Err(:final failure):
        emit(WorkOrderError(workOrders: _workOrders, mechanics: _mechanics, message: failure.message));
    }
  }

  Future<void> fetchWorkOrderDetail(String id) async {
    emit(WorkOrderLoading(workOrders: _workOrders, mechanics: _mechanics));
    final result = await _getWorkOrderDetail(id);
    switch (result) {
      case Success(:final data):
        emit(WorkOrderDetailLoaded(workOrders: _workOrders, mechanics: _mechanics, detail: data));
      case Err(:final failure):
        emit(WorkOrderError(workOrders: _workOrders, mechanics: _mechanics, message: failure.message));
    }
  }

  Future<void> fetchAvailableMechanics() async {
    emit(WorkOrderLoading(workOrders: _workOrders, mechanics: _mechanics));
    final result = await _getAvailableMechanics(const NoParams());
    switch (result) {
      case Success(:final data):
        _mechanics = data;
        emit(WorkOrderLoaded(workOrders: _workOrders, mechanics: _mechanics));
      case Err(:final failure):
        emit(WorkOrderError(workOrders: _workOrders, mechanics: _mechanics, message: failure.message));
    }
  }

  Future<void> assignMechanics({
    required String id,
    required List<Map<String, dynamic>> mechanics,
  }) async {
    emit(WorkOrderLoading(workOrders: _workOrders, mechanics: _mechanics));
    final result = await _assignMechanics(id: id, mechanics: mechanics);
    switch (result) {
      case Success(:final data):
        _updateList(data);
        emit(WorkOrderSuccess(
            workOrders: _workOrders,
            mechanics: _mechanics,
            message: 'Mecánicos asignados correctamente.',
            detail: data));
      case Err(:final failure):
        emit(WorkOrderError(workOrders: _workOrders, mechanics: _mechanics, message: failure.message));
    }
  }

  Future<void> assignDetails({
    required String id,
    required List<Map<String, dynamic>> details,
  }) async {
    emit(WorkOrderLoading(workOrders: _workOrders, mechanics: _mechanics));
    final result = await _assignDetails(id: id, details: details);
    switch (result) {
      case Success(:final data):
        _updateList(data);
        emit(WorkOrderSuccess(
            workOrders: _workOrders,
            mechanics: _mechanics,
            message: 'Detalles asignados correctamente.',
            detail: data));
      case Err(:final failure):
        emit(WorkOrderError(workOrders: _workOrders, mechanics: _mechanics, message: failure.message));
    }
  }

  Future<void> startWorkOrder(String id) async {
    emit(WorkOrderLoading(workOrders: _workOrders, mechanics: _mechanics));
    final result = await _startWorkOrder(id);
    switch (result) {
      case Success(:final data):
        _updateList(data);
        emit(WorkOrderSuccess(
            workOrders: _workOrders,
            mechanics: _mechanics,
            message: 'Orden de trabajo iniciada con éxito.',
            detail: data));
      case Err(:final failure):
        emit(WorkOrderError(workOrders: _workOrders, mechanics: _mechanics, message: failure.message));
    }
  }

  void _updateList(WorkOrder updated) {
    final idx = _workOrders.indexWhere((o) => o.id == updated.id);
    if (idx != -1) {
      final newList = List<WorkOrder>.from(_workOrders);
      newList[idx] = updated;
      _workOrders = newList;
    }
  }
}
