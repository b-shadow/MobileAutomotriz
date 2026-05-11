import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/work_order/data/models/work_order_model.dart';
import 'package:mobile1_app/features/workshop_progress/data/models/progress_log_model.dart';

abstract class WorkshopProgressRemoteDataSource {
  Future<List<WorkOrderModel>> getActiveWorkOrders();
  Future<WorkOrderModel> getWorkOrderDetail(String id);
  Future<WorkOrderDetailModel> startService(String orderId, String detailId);
  Future<WorkOrderDetailModel> pauseService(String orderId, String detailId, String reason);
  Future<WorkOrderDetailModel> finishService(String orderId, String detailId, int realTime, String obs);
  Future<WorkOrderDetailModel> markAsUnnecessary(String orderId, String detailId, String reason);
  Future<WorkOrderModel> finishWorkOrder(String orderId);
  Future<List<ProgressLogModel>> getProgressHistory(String orderId);
  Future<String> addManualProgress({
    required String citaId,
    String? detailId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  });
}

class WorkshopProgressRemoteDataSourceImpl implements WorkshopProgressRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const WorkshopProgressRemoteDataSourceImpl({
    required this.apiClient,
    required this.sessionStorage,
  });

  String get _slug {
    final userData = sessionStorage.userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      final slug = tenant['slug'] as String?;
      if (slug != null && slug.isNotEmpty) return slug;
    }
    return EnvConfig.tenantSlug;
  }

  @override
  Future<List<WorkOrderModel>> getActiveWorkOrders() async {
    try {
      final response = await apiClient.get(ApiConstants.avanceTallerList(_slug));
      final List<dynamic> rows;
      if (response.data is Map<String, dynamic> && response.data['results'] is List) {
        rows = response.data['results'] as List<dynamic>;
      } else if (response.data is List<dynamic>) {
        rows = response.data as List<dynamic>;
      } else {
        rows = const [];
      }
      return rows.whereType<Map<String, dynamic>>().map(WorkOrderModel.fromJson).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderModel> getWorkOrderDetail(String id) async {
    try {
      final response = await apiClient.get(ApiConstants.avanceTallerDetalle(_slug, id));
      return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderDetailModel> startService(String orderId, String detailId) async {
    try {
      final response = await apiClient.post(
        ApiConstants.avanceTallerIniciar(_slug, orderId),
        data: {'detalle_id': detailId},
      );
      return WorkOrderDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderDetailModel> pauseService(String orderId, String detailId, String reason) async {
    try {
      final response = await apiClient.post(
        ApiConstants.avanceTallerPausar(_slug, orderId),
        data: {'detalle_id': detailId, 'motivo': reason},
      );
      return WorkOrderDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderDetailModel> finishService(String orderId, String detailId, int realTime, String obs) async {
    try {
      final response = await apiClient.post(
        ApiConstants.avanceTallerFinalizar(_slug, orderId),
        data: {'detalle_id': detailId, 'tiempo_real_min': realTime, 'observaciones_mecanico': obs},
      );
      return WorkOrderDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderDetailModel> markAsUnnecessary(String orderId, String detailId, String reason) async {
    try {
      final response = await apiClient.post(
        ApiConstants.avanceTallerInnecesario(_slug, orderId),
        data: {'detalle_id': detailId, 'motivo': reason},
      );
      return WorkOrderDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderModel> finishWorkOrder(String orderId) async {
    try {
      final response = await apiClient.post(ApiConstants.avanceTallerFinalizarOrden(_slug, orderId));
      return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ProgressLogModel>> getProgressHistory(String orderId) async {
    try {
      // Obtenemos los detalles de la orden para saber su citaId
      final orderRes = await apiClient.get(ApiConstants.avanceTallerDetalle(_slug, orderId));
      final citaId = (orderRes.data['cita'] ?? '').toString();

      final response = await apiClient.get(ApiConstants.avancesVehiculoList(_slug));
      final List<dynamic> rows;
      if (response.data is List<dynamic>) {
        rows = response.data as List<dynamic>;
      } else {
        rows = const [];
      }
      
      // Filtramos en memoria los avances que corresponden a la cita de esta orden
      return rows
          .whereType<Map<String, dynamic>>()
          .map(ProgressLogModel.fromJson)
          .where((log) => log.citaId == citaId)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> addManualProgress({
    required String citaId,
    String? detailId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  }) async {
    try {
      final payload = {
        'cita': citaId,
        'tipo': type,
        'estado_nuevo': status,
        'mensaje': message,
      };
      if (detailId != null && detailId.isNotEmpty) {
        payload['orden_detalle'] = detailId;
      }
      if (percentage != null) {
        payload['porcentaje_avance'] = percentage.toString();
      }
      final response = await apiClient.post(ApiConstants.avancesVehiculoList(_slug), data: payload);
      return (response.data['id'] ?? '').toString();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
