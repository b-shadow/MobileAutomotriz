import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';
import 'package:mobile1_app/features/store_sales/domain/repositories/store_sales_repository.dart';

export 'mark_payment_received.dart';
export 'create_invoice.dart';

class GetStoreSales implements UseCase<List<StoreSale>, NoParams> {
  final StoreSalesRepository repository;
  GetStoreSales(this.repository);

  @override
  Future<Result<List<StoreSale>>> call(NoParams params) => repository.getSales();
}

class CreateStoreSale implements UseCase<StoreSale, StoreSaleInput> {
  final StoreSalesRepository repository;
  CreateStoreSale(this.repository);

  @override
  Future<Result<StoreSale>> call(StoreSaleInput params) => repository.createSale(params);
}

class ConfirmStoreSale {
  final StoreSalesRepository repository;
  ConfirmStoreSale(this.repository);

  Future<Result<StoreSale>> call(String saleId) => repository.confirmSale(saleId);
}

class CreatePaymentTaller {
  final StoreSalesRepository repository;
  CreatePaymentTaller(this.repository);

  Future<Result<String>> call({
    required String saleId,
    required double total,
    required String metodoPago,
  }) => repository.createPaymentTaller(
        saleId: saleId,
        total: total,
        metodoPago: metodoPago,
      );
}
