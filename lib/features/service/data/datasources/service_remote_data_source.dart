import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/service/data/models/service_item_model.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceItemModel>> getServices();
  Future<ServiceItemModel> createService(Map<String, dynamic> data);
  Future<ServiceItemModel> updateService({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<ServiceItemModel> updateServiceStatus({
    required String id,
    required bool activo,
    String? motivo,
  });
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const ServiceRemoteDataSourceImpl({
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
  Future<List<ServiceItemModel>> getServices() async {
    try {
      final response = await apiClient.get(ApiConstants.servicios(_slug));
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
          .map(ServiceItemModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ServiceItemModel> createService(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiConstants.servicios(_slug),
        data: data,
      );
      return ServiceItemModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ServiceItemModel> updateService({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiClient.patch(
        ApiConstants.servicio(_slug, id),
        data: data,
      );
      return ServiceItemModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ServiceItemModel> updateServiceStatus({
    required String id,
    required bool activo,
    String? motivo,
  }) async {
    try {
      final payload = <String, dynamic>{'activo': activo};
      if (motivo != null && motivo.trim().isNotEmpty) {
        payload['motivo'] = motivo.trim();
      }

      final response = await apiClient.patch(
        ApiConstants.servicioEstado(_slug, id),
        data: payload,
      );
      return ServiceItemModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

