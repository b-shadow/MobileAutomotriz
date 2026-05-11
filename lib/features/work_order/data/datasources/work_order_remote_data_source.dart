import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/work_order/data/models/work_order_model.dart';

abstract class WorkOrderRemoteDataSource {
  Future<List<WorkOrderModel>> getWorkOrders();
  Future<WorkOrderModel> getWorkOrderDetail(String id);
  Future<List<MechanicModel>> getAvailableMechanics();
  Future<WorkOrderModel> assignMechanics(String id, List<Map<String, dynamic>> mechanics);
  Future<WorkOrderModel> assignDetails(String id, List<Map<String, dynamic>> details);
  Future<WorkOrderModel> startWorkOrder(String id);
}

class WorkOrderRemoteDataSourceImpl implements WorkOrderRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const WorkOrderRemoteDataSourceImpl({
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
  Future<List<WorkOrderModel>> getWorkOrders() async {
    try {
      final response = await apiClient.get(ApiConstants.ordenesTrabajo(_slug));
      final data = response.data;
      final List<dynamic> rows;
      if (data is Map<String, dynamic> && data['results'] is List) {
        rows = data['results'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        rows = data;
      } else {
        rows = const [];
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(WorkOrderModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderModel> getWorkOrderDetail(String id) async {
    try {
      final response = await apiClient.get(ApiConstants.ordenTrabajo(_slug, id));
      return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<MechanicModel>> getAvailableMechanics() async {
    try {
      final response = await apiClient.get(ApiConstants.mecanicosDisponibles(_slug));
      final List<dynamic> rows;
      if (response.data is List<dynamic>) {
        rows = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic> && response.data['results'] is List) {
        rows = response.data['results'] as List<dynamic>;
      } else {
        rows = const [];
      }
      return rows
          .whereType<Map<String, dynamic>>()
          .map(MechanicModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderModel> assignMechanics(String id, List<Map<String, dynamic>> mechanics) async {
    try {
      final response = await apiClient.post(
        ApiConstants.asignarMecanicos(_slug, id),
        data: {'mecanicos': mechanics},
      );
      return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderModel> assignDetails(String id, List<Map<String, dynamic>> details) async {
    try {
      final response = await apiClient.post(
        ApiConstants.asignarDetalles(_slug, id),
        data: {'detalles': details},
      );
      return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkOrderModel> startWorkOrder(String id) async {
    try {
      final response = await apiClient.post(ApiConstants.iniciarOrdenTrabajo(_slug, id));
      return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
