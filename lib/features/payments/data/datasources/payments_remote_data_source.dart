import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/payments/data/models/payment_taller_model.dart';

abstract class PaymentsRemoteDataSource {
  Future<List<PaymentTallerModel>> getPayments();
  Future<PaymentTallerModel> createPayment(Map<String, dynamic> data);
  Future<PaymentTallerModel> markReceived(String paymentId);
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const PaymentsRemoteDataSourceImpl({
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

  List<PaymentTallerModel> _parseList(dynamic data) {
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
        .map(PaymentTallerModel.fromJson)
        .toList();
  }

  @override
  Future<List<PaymentTallerModel>> getPayments() async {
    try {
      final response = await apiClient
          .get('/api/$_slug/gestion-administrativa/pagos-taller/');
      return _parseList(response.data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  String? get _empresaId {
    final userData = sessionStorage.userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      return tenant['id']?.toString();
    }
    return null;
  }

  @override
  Future<PaymentTallerModel> createPayment(Map<String, dynamic> data) async {
    try {
      final payload = {...data, 'empresa': _empresaId};
      final response = await apiClient
          .post('/api/$_slug/gestion-administrativa/pagos-taller/', data: payload);
      return PaymentTallerModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PaymentTallerModel> markReceived(String paymentId) async {
    try {
      final response = await apiClient.post(
          '/api/$_slug/gestion-administrativa/pagos-taller/$paymentId/marcar-recibido/');
      return PaymentTallerModel.fromJson(
          response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
