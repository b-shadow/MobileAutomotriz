import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/inventory/data/models/inventory_category_model.dart';
import 'package:mobile1_app/features/inventory/data/models/inventory_item_model.dart';
import 'package:mobile1_app/features/inventory/data/models/inventory_movement_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryCategoryModel>> getCategories();
  Future<InventoryCategoryModel> createCategory(Map<String, dynamic> data);
  Future<List<InventoryItemModel>> getItems();
  Future<InventoryItemModel> createItem(Map<String, dynamic> data);
  Future<InventoryMovementModel> adjustStock(
      String itemId, Map<String, dynamic> data);
  Future<List<InventoryMovementModel>> getMovements();
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const InventoryRemoteDataSourceImpl({
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

  List<T> _parseList<T>(
      dynamic data, T Function(Map<String, dynamic>) fromJson) {
    final List<dynamic> rows;
    if (data is Map<String, dynamic> && data['results'] is List) {
      rows = data['results'] as List<dynamic>;
    } else if (data is List<dynamic>) {
      rows = data;
    } else {
      rows = const [];
    }
    return rows.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  // ── Categories ──────────────────────────────────────────

  @override
  Future<List<InventoryCategoryModel>> getCategories() async {
    try {
      final response =
          await apiClient.get(ApiConstants.categoriasInventario(_slug));
      return _parseList(response.data, InventoryCategoryModel.fromJson);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<InventoryCategoryModel> createCategory(
      Map<String, dynamic> data) async {
    try {
      final response = await apiClient
          .post(ApiConstants.categoriasInventario(_slug), data: data);
      return InventoryCategoryModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Items ───────────────────────────────────────────────

  @override
  Future<List<InventoryItemModel>> getItems() async {
    try {
      final response =
          await apiClient.get(ApiConstants.inventarioItems(_slug));
      return _parseList(response.data, InventoryItemModel.fromJson);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<InventoryItemModel> createItem(Map<String, dynamic> data) async {
    try {
      final response = await apiClient
          .post(ApiConstants.inventarioItems(_slug), data: data);
      return InventoryItemModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<InventoryMovementModel> adjustStock(
      String itemId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient
          .post(ApiConstants.ajustarStock(_slug, itemId), data: data);
      return InventoryMovementModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Movements ───────────────────────────────────────────

  @override
  Future<List<InventoryMovementModel>> getMovements() async {
    try {
      final response =
          await apiClient.get(ApiConstants.movimientosInventario(_slug));
      return _parseList(response.data, InventoryMovementModel.fromJson);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
