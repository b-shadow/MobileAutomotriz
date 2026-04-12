import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/company/data/models/empresa_model.dart';
import 'package:mobile1_app/features/company/data/models/plan_model.dart';
import 'package:mobile1_app/features/company/data/models/subscription_model.dart';

abstract class CompanyRemoteDataSource {
  Future<EmpresaModel> getMyCompany();
  Future<EmpresaModel> updateMyCompany({String? nombre, String? estado});
  Future<SubscriptionModel> getCurrentSubscription();
  Future<List<PlanModel>> getAvailablePlans();
  Future<Map<String, dynamic>> changePlan(String planId);
  Future<Map<String, dynamic>> createPaymentIntent({
    required String planId,
    required String accion,
  });
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String planId,
    required String accion,
  });
  Future<Map<String, dynamic>> cancelScheduledChange();
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const CompanyRemoteDataSourceImpl({
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
  Future<EmpresaModel> getMyCompany() async {
    try {
      final response = await apiClient.get(ApiConstants.miEmpresa(_slug));
      return EmpresaModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SubscriptionModel> getCurrentSubscription() async {
    try {
      final response = await apiClient.get(
        ApiConstants.suscripcionActual(_slug),
      );
      return SubscriptionModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<EmpresaModel> updateMyCompany({String? nombre, String? estado}) async {
    try {
      final Map<String, dynamic> data = {};
      if (nombre != null) data['nombre'] = nombre;
      if (estado != null) data['estado'] = estado;

      final response = await apiClient.patch(
        ApiConstants.miEmpresa(_slug),
        data: data,
      );
      return EmpresaModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<PlanModel>> getAvailablePlans() async {
    try {
      final response = await apiClient.get(ApiConstants.planes);
      final data = response.data;

      // Handle paginated response { count, results: [...] }
      List<dynamic> results;
      if (data is Map<String, dynamic> && data.containsKey('results')) {
        results = data['results'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        results = data;
      } else {
        results = [];
      }

      return results
          .map((json) => PlanModel.fromJson(json as Map<String, dynamic>))
          .where((plan) => plan.activo)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> changePlan(String planId) async {
    try {
      final response = await apiClient.post(
        ApiConstants.cambiarPlan(_slug),
        data: {'planId': planId},
      );
      return response.data as Map<String, dynamic>;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> createPaymentIntent({
    required String planId,
    required String accion,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.crearPaymentIntent(_slug),
        data: {'planId': planId, 'accion': accion},
      );
      return response.data as Map<String, dynamic>;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
    required String planId,
    required String accion,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.confirmarPago(_slug),
        data: {
          'paymentIntentId': paymentIntentId,
          'planId': planId,
          'accion': accion,
        },
      );
      return response.data as Map<String, dynamic>;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> cancelScheduledChange() async {
    try {
      final response = await apiClient.post(ApiConstants.cancelarCambio(_slug));
      return response.data as Map<String, dynamic>;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
