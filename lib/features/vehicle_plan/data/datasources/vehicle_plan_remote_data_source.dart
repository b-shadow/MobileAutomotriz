import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/vehicle_plan/data/models/vehicle_plan_detail_model.dart';
import 'package:mobile1_app/features/vehicle_plan/data/models/vehicle_plan_model.dart';

abstract class VehiclePlanRemoteDataSource {
  Future<List<VehiclePlanModel>> getPlans();
  Future<VehiclePlanModel> getPlanDetail(String planId);
  Future<VehiclePlanModel> updatePlan({required String planId, required Map<String, dynamic> data});
  Future<VehiclePlanModel> updatePlanStatus({required String planId, required String estado, String? motivo});
  Future<List<VehiclePlanDetailModel>> getPlanDetails(String planId);
  Future<VehiclePlanDetailModel> createPlanDetail({required String planId, required Map<String, dynamic> data});
  Future<VehiclePlanDetailModel> updatePlanDetail({required String detailId, required Map<String, dynamic> data});
  Future<VehiclePlanDetailModel> updatePlanDetailStatus({required String detailId, required String estado, String? motivo});
}

class VehiclePlanRemoteDataSourceImpl implements VehiclePlanRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const VehiclePlanRemoteDataSourceImpl({
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
  Future<List<VehiclePlanModel>> getPlans() async {
    try {
      final response = await apiClient.get(ApiConstants.planesVehiculo(_slug));
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
          .map(VehiclePlanModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehiclePlanModel> getPlanDetail(String planId) async {
    try {
      final response = await apiClient.get(ApiConstants.planVehiculo(_slug, planId));
      return VehiclePlanModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehiclePlanModel> updatePlan({required String planId, required Map<String, dynamic> data}) async {
    try {
      final response = await apiClient.patch(ApiConstants.planVehiculo(_slug, planId), data: data);
      return VehiclePlanModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehiclePlanModel> updatePlanStatus({required String planId, required String estado, String? motivo}) async {
    try {
      final payload = <String, dynamic>{'estado': estado};
      if ((motivo ?? '').trim().isNotEmpty) payload['motivo'] = motivo!.trim();
      final response = await apiClient.patch(ApiConstants.planVehiculoEstado(_slug, planId), data: payload);
      return VehiclePlanModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<VehiclePlanDetailModel>> getPlanDetails(String planId) async {
    try {
      final response = await apiClient.get(ApiConstants.planVehiculoDetalles(_slug, planId));
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
          .map(VehiclePlanDetailModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehiclePlanDetailModel> createPlanDetail({required String planId, required Map<String, dynamic> data}) async {
    try {
      final response = await apiClient.post(ApiConstants.planVehiculoCrearDetalle(_slug, planId), data: data);
      final json = response.data is Map<String, dynamic>
          ? (response.data as Map<String, dynamic>)
          : <String, dynamic>{};
      return VehiclePlanDetailModel.fromJson((json['detalle'] as Map<String, dynamic>?) ?? json);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehiclePlanDetailModel> updatePlanDetail({required String detailId, required Map<String, dynamic> data}) async {
    try {
      final response = await apiClient.patch(ApiConstants.planVehiculoEditarDetalle(_slug, detailId), data: data);
      final json = response.data is Map<String, dynamic>
          ? (response.data as Map<String, dynamic>)
          : <String, dynamic>{};
      return VehiclePlanDetailModel.fromJson((json['detalle'] as Map<String, dynamic>?) ?? json);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehiclePlanDetailModel> updatePlanDetailStatus({required String detailId, required String estado, String? motivo}) async {
    try {
      final payload = <String, dynamic>{'estado': estado};
      if ((motivo ?? '').trim().isNotEmpty) payload['motivo'] = motivo!.trim();
      final response = await apiClient.patch(ApiConstants.planVehiculoDetalleEstado(_slug, detailId), data: payload);
      final json = response.data is Map<String, dynamic>
          ? (response.data as Map<String, dynamic>)
          : <String, dynamic>{};
      return VehiclePlanDetailModel.fromJson((json['detalle'] as Map<String, dynamic>?) ?? json);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

