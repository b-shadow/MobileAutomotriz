import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/supplier/domain/repositories/supplier_repository.dart';

class DeleteSupplier implements UseCase<void, String> {
  final SupplierRepository repository;
  DeleteSupplier(this.repository);

  @override
  Future<Result<void>> call(String id) => repository.deleteSupplier(id);
}
