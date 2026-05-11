import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';

sealed class WorkOrderState extends Equatable {
  final List<WorkOrder> workOrders;
  final List<Mechanic> mechanics;

  const WorkOrderState({
    this.workOrders = const [],
    this.mechanics = const [],
  });

  @override
  List<Object?> get props => [workOrders, mechanics];
}

final class WorkOrderInitial extends WorkOrderState {
  const WorkOrderInitial();
}

final class WorkOrderLoading extends WorkOrderState {
  const WorkOrderLoading({super.workOrders, super.mechanics});
}

final class WorkOrderLoaded extends WorkOrderState {
  const WorkOrderLoaded({required super.workOrders, super.mechanics});
}

final class WorkOrderDetailLoaded extends WorkOrderState {
  final WorkOrder detail;

  const WorkOrderDetailLoaded({
    required super.workOrders,
    required super.mechanics,
    required this.detail,
  });

  @override
  List<Object?> get props => [workOrders, mechanics, detail];
}

final class WorkOrderSuccess extends WorkOrderState {
  final String message;
  final WorkOrder? detail;

  const WorkOrderSuccess({
    required super.workOrders,
    required super.mechanics,
    required this.message,
    this.detail,
  });

  @override
  List<Object?> get props => [workOrders, mechanics, message, detail];
}

final class WorkOrderError extends WorkOrderState {
  final String message;

  const WorkOrderError({
    required super.workOrders,
    required super.mechanics,
    required this.message,
  });

  @override
  List<Object?> get props => [workOrders, mechanics, message];
}
