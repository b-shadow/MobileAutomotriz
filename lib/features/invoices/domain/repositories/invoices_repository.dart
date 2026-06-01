import 'package:mobile1_app/core/error/result.dart';
import '../entities/invoice_entity.dart';

abstract class InvoicesRepository {
  Future<Result<List<InvoiceEntity>>> getInvoices();
}
