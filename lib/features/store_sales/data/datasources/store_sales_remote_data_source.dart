import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/store_sales/data/models/store_sale_model.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';

abstract class StoreSalesRemoteDataSource {
  Future<List<StoreSaleModel>> getSales();
  Future<StoreSaleModel> createSale(StoreSaleInput input);
  Future<StoreSaleModel> confirmSale(String saleId);
  Future<void> markPaymentReceived(String pagoId);
  Future<void> createInvoice(String pagoId);
  Future<String> createPaymentTaller({
    required String saleId,
    required double total,
    required String metodoPago,
  });
}

class StoreSalesRemoteDataSourceImpl implements StoreSalesRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const StoreSalesRemoteDataSourceImpl({
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
  Future<List<StoreSaleModel>> getSales() async {
    try {
      final response = await apiClient.get('/api/$_slug/gestion-administrativa/ventas-mostrador/');
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
          .map(StoreSaleModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<StoreSaleModel> createSale(StoreSaleInput input) async {
    try {
      final response = await apiClient.post(
        '/api/$_slug/gestion-administrativa/ventas-mostrador/',
        data: input.toJson(),
      );
      return StoreSaleModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<StoreSaleModel> confirmSale(String saleId) async {
    try {
      final response = await apiClient.post(
        '/api/$_slug/gestion-administrativa/ventas-mostrador/$saleId/confirmar/',
      );
      return StoreSaleModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markPaymentReceived(String pagoId) async {
    try {
      await apiClient.post(
          '/api/$_slug/gestion-administrativa/pagos-taller/$pagoId/marcar-recibido/');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> createInvoice(String pagoId) async {
    try {
      await apiClient.post(
        '/api/$_slug/gestion-administrativa/facturas/',
        data: {'pago_taller': pagoId},
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> createPaymentTaller({
    required String saleId,
    required double total,
    required String metodoPago,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/$_slug/gestion-administrativa/pagos-taller/',
        data: {
          'tipo_origen': 'VENTA',
          'venta': saleId,
          'tipo_destino': 'VENTA',
          'id_destino': saleId,
          'estado': 'PENDIENTE',
          'monto_total': total,
          'monto_real': total,
          'monto_cobrado': total,
          'metodo_pago': metodoPago,
          'moneda': 'BOB',
          'descripcion': 'Pago venta mostrador $saleId',
        },
      );
      final data = response.data as Map<String, dynamic>;
      return (data['id'] ?? '').toString();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
