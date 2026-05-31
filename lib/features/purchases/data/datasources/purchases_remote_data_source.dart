import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/purchases/data/models/purchase_model.dart';
import 'package:mobile1_app/features/purchases/domain/entities/purchase_entity.dart';

abstract class PurchasesRemoteDataSource {
  Future<List<PurchaseModel>> getPurchases();
  Future<PurchaseModel> createPurchase(PurchaseInput input);
  Future<PurchaseModel> markAsReceived(String purchaseId);
}

class PurchasesRemoteDataSourceImpl implements PurchasesRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const PurchasesRemoteDataSourceImpl({
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
  Future<List<PurchaseModel>> getPurchases() async {
    try {
      final response = await apiClient.get('/api/$_slug/gestion-administrativa/compras/');
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
          .map(PurchaseModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PurchaseModel> createPurchase(PurchaseInput input) async {
    try {
      final response = await apiClient.post(
        '/api/$_slug/gestion-administrativa/compras/',
        data: input.toJson(),
      );
      return PurchaseModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PurchaseModel> markAsReceived(String purchaseId) async {
    try {
      final response = await apiClient.post(
        '/api/$_slug/gestion-administrativa/compras/$purchaseId/marcar-recibida/',
      );
      return PurchaseModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
