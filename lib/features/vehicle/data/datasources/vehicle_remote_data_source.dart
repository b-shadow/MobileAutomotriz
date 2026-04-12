import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/vehicle/data/models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> getVehicles();
  Future<VehicleModel> createVehicle(Map<String, dynamic> data);
  Future<VehicleModel> updateVehicle({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<VehicleModel> updateVehicleStatus({
    required String id,
    required String estado,
    String? motivo,
  });
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const VehicleRemoteDataSourceImpl({
    required this.apiClient,
    required this.sessionStorage,
  });

  String get _slug {
    final userData = sessionStorage.userData;
    if (userData != null && userData['tenant'] != null) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      final slug = tenant['slug'] as String?;
      if (slug != null && slug.isNotEmpty) return slug;
    }
    return EnvConfig.tenantSlug;
  }

  @override
  Future<List<VehicleModel>> getVehicles() async {
    try {
      final response = await apiClient.get(ApiConstants.vehiculos(_slug));
      final data = response.data;

      List<dynamic> rows;
      if (data is Map<String, dynamic> && data['results'] is List) {
        rows = data['results'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        rows = data;
      } else {
        rows = const [];
      }

      return rows
          .whereType<Map<String, dynamic>>()
          .map(VehicleModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleModel> createVehicle(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiConstants.vehiculos(_slug),
        data: data,
      );
      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleModel> updateVehicle({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiClient.patch(
        ApiConstants.vehiculo(_slug, id),
        data: data,
      );
      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleModel> updateVehicleStatus({
    required String id,
    required String estado,
    String? motivo,
  }) async {
    try {
      final payload = <String, dynamic>{'estado': estado};
      if (motivo != null && motivo.trim().isNotEmpty) {
        payload['motivo'] = motivo.trim();
      }

      final response = await apiClient.patch(
        '/api/$_slug/vehiculos/$id/estado/',
        data: payload,
      );
      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}



