import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/store_sales/domain/repositories/store_sales_repository.dart';

class CreateInvoice {
  final StoreSalesRepository repository;

  CreateInvoice(this.repository);

  Future<Result<void>> call(String pagoId) async {
    return repository.createInvoice(pagoId);
  }
}
