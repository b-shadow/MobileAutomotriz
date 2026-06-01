import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';

abstract class StoreSalesRepository {
  Future<Result<List<StoreSale>>> getSales();

  Future<Result<StoreSale>> createSale(StoreSaleInput input);

  Future<Result<StoreSale>> confirmSale(String saleId);

  Future<Result<void>> markPaymentReceived(String pagoId);

  Future<Result<void>> createInvoice(String pagoId);

  Future<Result<String>> createPaymentTaller({
    required String saleId,
    required double total,
    required String metodoPago,
  });
}
