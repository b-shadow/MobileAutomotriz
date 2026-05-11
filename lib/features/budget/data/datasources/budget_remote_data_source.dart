import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/budget/data/models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<BudgetModel> getBudgetDetail(String id);
  Future<BudgetModel> createBudget(Map<String, dynamic> data);
  Future<BudgetModel> updateBudget(String id, Map<String, dynamic> data);
  Future<BudgetModel> changeStatus(String id, String action, {String? motivo});
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const BudgetRemoteDataSourceImpl({
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
  Future<List<BudgetModel>> getBudgets() async {
    try {
      final response = await apiClient.get(ApiConstants.presupuestos(_slug));
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
          .map(BudgetModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<BudgetModel> getBudgetDetail(String id) async {
    try {
      final response = await apiClient.get(ApiConstants.presupuesto(_slug, id));
      return BudgetModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<BudgetModel> createBudget(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(ApiConstants.presupuestos(_slug), data: data);
      return BudgetModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<BudgetModel> updateBudget(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.patch(ApiConstants.presupuesto(_slug, id), data: data);
      return BudgetModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<BudgetModel> changeStatus(String id, String action, {String? motivo}) async {
    try {
      String url;
      switch (action) {
        case 'comunicar': url = ApiConstants.comunicarPresupuesto(_slug, id); break;
        case 'aprobar': url = ApiConstants.aprobarPresupuesto(_slug, id); break;
        case 'rechazar': url = ApiConstants.rechazarPresupuesto(_slug, id); break;
        case 'ajustar': url = ApiConstants.ajustarPresupuesto(_slug, id); break;
        case 'cerrar': url = ApiConstants.cerrarPresupuesto(_slug, id); break;
        default: throw ServerException(message: 'Acción no válida');
      }

      final data = <String, dynamic>{};
      if (motivo != null && motivo.isNotEmpty) {
        data['motivo'] = motivo;
      }

      final response = await apiClient.post(url, data: data);
      return BudgetModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
