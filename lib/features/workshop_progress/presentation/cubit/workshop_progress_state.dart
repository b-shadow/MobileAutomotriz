import 'package:equatable/equatable.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';

sealed class WorkshopProgressState extends Equatable {
  final List<WorkOrder> activeOrders;
  final List<ProgressLog> history;
  final List<InventoryItem> inventoryItems;
  final List<SparePartRequest> sparePartRequests;

  const WorkshopProgressState({
    this.activeOrders = const [],
    this.history = const [],
    this.inventoryItems = const [],
    this.sparePartRequests = const [],
  });

  @override
  List<Object?> get props => [activeOrders, history, inventoryItems, sparePartRequests];
}

final class WorkshopProgressInitial extends WorkshopProgressState {
  const WorkshopProgressInitial();
}

final class WorkshopProgressLoading extends WorkshopProgressState {
  const WorkshopProgressLoading({
    super.activeOrders,
    super.history,
    super.inventoryItems,
    super.sparePartRequests,
  });
}

final class WorkshopProgressLoaded extends WorkshopProgressState {
  const WorkshopProgressLoaded({
    required super.activeOrders,
    super.history,
    super.inventoryItems,
    super.sparePartRequests,
  });
}

final class WorkshopProgressDetailLoaded extends WorkshopProgressState {
  final WorkOrder detail;

  const WorkshopProgressDetailLoaded({
    required super.activeOrders,
    required super.history,
    required this.detail,
    super.inventoryItems,
    super.sparePartRequests,
  });

  @override
  List<Object?> get props => [activeOrders, history, detail, inventoryItems, sparePartRequests];
}

final class WorkshopProgressHistoryLoaded extends WorkshopProgressState {
  final WorkOrder detail;

  const WorkshopProgressHistoryLoaded({
    required super.activeOrders,
    required super.history,
    required this.detail,
    super.inventoryItems,
    super.sparePartRequests,
  });

  @override
  List<Object?> get props => [activeOrders, history, detail, inventoryItems, sparePartRequests];
}

final class WorkshopProgressSuccess extends WorkshopProgressState {
  final String message;
  final WorkOrder? detail;

  const WorkshopProgressSuccess({
    required super.activeOrders,
    required super.history,
    required this.message,
    this.detail,
    super.inventoryItems,
    super.sparePartRequests,
  });

  @override
  List<Object?> get props => [activeOrders, history, message, detail, inventoryItems, sparePartRequests];
}

final class WorkshopProgressError extends WorkshopProgressState {
  final String message;

  const WorkshopProgressError({
    required super.activeOrders,
    required super.history,
    required this.message,
    super.inventoryItems,
    super.sparePartRequests,
  });

  @override
  List<Object?> get props => [activeOrders, history, message, inventoryItems, sparePartRequests];
}
