import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import '../entities/invoice_entity.dart';
import '../repositories/invoices_repository.dart';

class GetInvoices implements UseCase<List<InvoiceEntity>, NoParams> {
  final InvoicesRepository repository;

  GetInvoices(this.repository);

  @override
  Future<Result<List<InvoiceEntity>>> call(NoParams params) =>
      repository.getInvoices();
}
