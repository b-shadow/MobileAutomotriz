import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/workshop_progress/domain/entities/progress_log.dart';
import 'package:mobile1_app/features/workshop_progress/domain/repositories/workshop_progress_repository.dart';

class GetActiveWorkOrders implements UseCase<List<WorkOrder>, NoParams> {
  final WorkshopProgressRepository repository;
  GetActiveWorkOrders(this.repository);

  @override
  Future<Result<List<WorkOrder>>> call(NoParams params) =>
      repository.getActiveWorkOrders();
}

class GetProgressWorkOrderDetail implements UseCase<WorkOrder, String> {
  final WorkshopProgressRepository repository;
  GetProgressWorkOrderDetail(this.repository);

  @override
  Future<Result<WorkOrder>> call(String params) =>
      repository.getWorkOrderDetail(params);
}

class GetProgressHistory implements UseCase<List<ProgressLog>, String> {
  final WorkshopProgressRepository repository;
  GetProgressHistory(this.repository);

  @override
  Future<Result<List<ProgressLog>>> call(String params) =>
      repository.getProgressHistory(params);
}

class StartService {
  final WorkshopProgressRepository repository;
  StartService(this.repository);

  Future<Result<WorkOrderDetail>> call(String orderId, String detailId) =>
      repository.startService(orderId, detailId);
}

class PauseService {
  final WorkshopProgressRepository repository;
  PauseService(this.repository);

  Future<Result<WorkOrderDetail>> call({
    required String orderId,
    required String detailId,
    required String reason,
  }) =>
      repository.pauseService(orderId: orderId, detailId: detailId, reason: reason);
}

class FinishService {
  final WorkshopProgressRepository repository;
  FinishService(this.repository);

  Future<Result<WorkOrderDetail>> call({
    required String orderId,
    required String detailId,
    required int realTimeMinutes,
    String observations = '',
  }) =>
      repository.finishService(
          orderId: orderId,
          detailId: detailId,
          realTimeMinutes: realTimeMinutes,
          observations: observations);
}

class MarkServiceUnnecessary {
  final WorkshopProgressRepository repository;
  MarkServiceUnnecessary(this.repository);

  Future<Result<WorkOrderDetail>> call({
    required String orderId,
    required String detailId,
    required String reason,
  }) =>
      repository.markAsUnnecessary(
          orderId: orderId, detailId: detailId, reason: reason);
}

class FinishWorkOrder implements UseCase<WorkOrder, String> {
  final WorkshopProgressRepository repository;
  FinishWorkOrder(this.repository);

  @override
  Future<Result<WorkOrder>> call(String params) =>
      repository.finishWorkOrder(params);
}

class AddManualProgress {
  final WorkshopProgressRepository repository;
  AddManualProgress(this.repository);

  Future<Result<String>> call({
    required String citaId,
    String? detailId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  }) =>
      repository.addManualProgress(
          citaId: citaId,
          detailId: detailId,
          type: type,
          status: status,
          message: message,
          percentage: percentage);
}
