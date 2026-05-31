import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/supplier/data/models/supplier_model.dart';

abstract class SupplierRemoteDataSource {
  Future<List<SupplierModel>> getSuppliers();
  Future<SupplierModel> createSupplier(Map<String, dynamic> data);
  Future<SupplierModel> updateSupplier(String id, Map<String, dynamic> data);
  Future<void> deleteSupplier(String id);
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const SupplierRemoteDataSourceImpl({
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

  List<SupplierModel> _parseList(dynamic data) {
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
        .map(SupplierModel.fromJson)
        .toList();
  }

  @override
  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final response =
          await apiClient.get(ApiConstants.proveedores(_slug));
      return _parseList(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SupplierModel> createSupplier(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiConstants.proveedores(_slug),
        data: data,
      );
      return SupplierModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SupplierModel> updateSupplier(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        ApiConstants.proveedor(_slug, id),
        data: data,
      );
      return SupplierModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      await apiClient.delete(ApiConstants.proveedor(_slug, id));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
