import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/spare_parts/data/models/spare_part_request_model.dart';

abstract class SparePartsRemoteDataSource {
  Future<List<SparePartRequestModel>> getSolicitudes();

  Future<SparePartRequestModel> aprobarSolicitud(
      String solicitudId, Map<String, dynamic> data);

  Future<SparePartRequestModel> enProcesoAlmacen(
      String solicitudId, Map<String, dynamic> data);

  Future<SparePartRequestModel> marcarEntregada(
      String solicitudId, Map<String, dynamic> data);

  Future<SparePartRequestModel> asignarProveedorEta(
      String solicitudId, Map<String, dynamic> data);
}

class SparePartsRemoteDataSourceImpl implements SparePartsRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const SparePartsRemoteDataSourceImpl({
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

  List<SparePartRequestModel> _parseList(dynamic data) {
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
        .map(SparePartRequestModel.fromJson)
        .toList();
  }

  @override
  Future<List<SparePartRequestModel>> getSolicitudes() async {
    try {
      final response =
          await apiClient.get(ApiConstants.solicitudesRepuesto(_slug));
      return _parseList(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SparePartRequestModel> aprobarSolicitud(
      String solicitudId, Map<String, dynamic> data) async {
    try {
      final url =
          '${ApiConstants.solicitudRepuesto(_slug, solicitudId)}aprobar/';
      final response = await apiClient.post(url, data: data);
      return SparePartRequestModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SparePartRequestModel> enProcesoAlmacen(
      String solicitudId, Map<String, dynamic> data) async {
    try {
      final url =
          '${ApiConstants.solicitudRepuesto(_slug, solicitudId)}en-proceso-almacen/';
      final response = await apiClient.post(url, data: data);
      return SparePartRequestModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SparePartRequestModel> marcarEntregada(
      String solicitudId, Map<String, dynamic> data) async {
    try {
      final url =
          '${ApiConstants.solicitudRepuesto(_slug, solicitudId)}marcar-entregada/';
      final response = await apiClient.post(url, data: data);
      return SparePartRequestModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SparePartRequestModel> asignarProveedorEta(
      String solicitudId, Map<String, dynamic> data) async {
    try {
      final url =
          '${ApiConstants.solicitudRepuesto(_slug, solicitudId)}asignar-proveedor-eta/';
      final response = await apiClient.post(url, data: data);
      return SparePartRequestModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
