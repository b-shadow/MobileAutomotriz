import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';

abstract class StoreSalesRepository {
  Future<Result<List<StoreSale>>> getSales();

  Future<Result<StoreSale>> createSale(StoreSaleInput input);

  Future<Result<StoreSale>> confirmSale(String saleId);
}
