import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';

abstract class WorkOrderRepository {
  Future<Result<List<WorkOrder>>> getWorkOrders();
  
  Future<Result<WorkOrder>> getWorkOrderDetail(String id);
  
  Future<Result<List<Mechanic>>> getAvailableMechanics();
  
  Future<Result<WorkOrder>> assignMechanics({
    required String id,
    required List<Map<String, dynamic>> mechanics,
  });
  
  Future<Result<WorkOrder>> assignDetails({
    required String id,
    required List<Map<String, dynamic>> details,
  });
  
  Future<Result<WorkOrder>> startWorkOrder(String id);
}
