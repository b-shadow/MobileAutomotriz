import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';
import 'package:mobile1_app/features/work_order/domain/repositories/work_order_repository.dart';

class GetWorkOrders implements UseCase<List<WorkOrder>, NoParams> {
  final WorkOrderRepository repository;
  GetWorkOrders(this.repository);

  @override
  Future<Result<List<WorkOrder>>> call(NoParams params) =>
      repository.getWorkOrders();
}

class GetWorkOrderDetail implements UseCase<WorkOrder, String> {
  final WorkOrderRepository repository;
  GetWorkOrderDetail(this.repository);

  @override
  Future<Result<WorkOrder>> call(String params) =>
      repository.getWorkOrderDetail(params);
}

class GetAvailableMechanics implements UseCase<List<Mechanic>, NoParams> {
  final WorkOrderRepository repository;
  GetAvailableMechanics(this.repository);

  @override
  Future<Result<List<Mechanic>>> call(NoParams params) =>
      repository.getAvailableMechanics();
}

class AssignMechanics {
  final WorkOrderRepository repository;
  AssignMechanics(this.repository);

  Future<Result<WorkOrder>> call({
    required String id,
    required List<Map<String, dynamic>> mechanics,
  }) =>
      repository.assignMechanics(id: id, mechanics: mechanics);
}

class AssignDetails {
  final WorkOrderRepository repository;
  AssignDetails(this.repository);

  Future<Result<WorkOrder>> call({
    required String id,
    required List<Map<String, dynamic>> details,
  }) =>
      repository.assignDetails(id: id, details: details);
}

class StartWorkOrder implements UseCase<WorkOrder, String> {
  final WorkOrderRepository repository;
  StartWorkOrder(this.repository);

  @override
  Future<Result<WorkOrder>> call(String params) =>
      repository.startWorkOrder(params);
}
