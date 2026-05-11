import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';

sealed class WorkshopProgressState extends Equatable {
  final List<WorkOrder> activeOrders;
  final List<ProgressLog> history;

  const WorkshopProgressState({
    this.activeOrders = const [],
    this.history = const [],
  });

  @override
  List<Object?> get props => [activeOrders, history];
}

final class WorkshopProgressInitial extends WorkshopProgressState {
  const WorkshopProgressInitial();
}

final class WorkshopProgressLoading extends WorkshopProgressState {
  const WorkshopProgressLoading({super.activeOrders, super.history});
}

final class WorkshopProgressLoaded extends WorkshopProgressState {
  const WorkshopProgressLoaded({required super.activeOrders, super.history});
}

final class WorkshopProgressDetailLoaded extends WorkshopProgressState {
  final WorkOrder detail;

  const WorkshopProgressDetailLoaded({
    required super.activeOrders,
    required super.history,
    required this.detail,
  });

  @override
  List<Object?> get props => [activeOrders, history, detail];
}

final class WorkshopProgressHistoryLoaded extends WorkshopProgressState {
  final WorkOrder detail;

  const WorkshopProgressHistoryLoaded({
    required super.activeOrders,
    required super.history,
    required this.detail,
  });

  @override
  List<Object?> get props => [activeOrders, history, detail];
}

final class WorkshopProgressSuccess extends WorkshopProgressState {
  final String message;
  final WorkOrder? detail;

  const WorkshopProgressSuccess({
    required super.activeOrders,
    required super.history,
    required this.message,
    this.detail,
  });

  @override
  List<Object?> get props => [activeOrders, history, message, detail];
}

final class WorkshopProgressError extends WorkshopProgressState {
  final String message;

  const WorkshopProgressError({
    required super.activeOrders,
    required super.history,
    required this.message,
  });

  @override
  List<Object?> get props => [activeOrders, history, message];
}
