import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/spare_part_entities.dart';

abstract class WorkshopProgressRepository {
  Future<Result<List<WorkOrder>>> getActiveWorkOrders();

  Future<Result<WorkOrder>> getWorkOrderDetail(String id);

  Future<Result<WorkOrderDetail>> startService(String orderId, String detailId);

  Future<Result<WorkOrderDetail>> pauseService({
    required String orderId,
    required String detailId,
    required String reason,
  });

  Future<Result<WorkOrderDetail>> finishService({
    required String orderId,
    required String detailId,
    required int realTimeMinutes,
    String observations = '',
  });

  Future<Result<WorkOrderDetail>> markAsUnnecessary({
    required String orderId,
    required String detailId,
    required String reason,
  });

  Future<Result<WorkOrder>> finishWorkOrder(String orderId);

  Future<Result<List<ProgressLog>>> getProgressHistory(String orderId);

  Future<Result<String>> addManualProgress({
    required String citaId,
    String? detailId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  });

  // ── Repuestos / Inventario ───────────────────────────────────────────────
  Future<Result<List<InventoryItem>>> getInventoryItems();

  Future<Result<List<SparePartRequest>>> getSparePartRequests({String? ordenGlobalId});

  Future<Result<void>> createSparePartRequest({
    required String citaId,
    required String ordenGlobalId,
    required String motivo,
    required List<SparePartRequestLine> lineas,
  });

  Future<Result<void>> markSparePartsReceived({
    required String solicitudId,
    required List<Map<String, dynamic>> detalles,
  });
}
