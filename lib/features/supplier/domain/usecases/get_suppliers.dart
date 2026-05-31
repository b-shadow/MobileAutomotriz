import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/supplier/domain/entities/supplier.dart';
import 'package:mobile1_app/features/supplier/domain/repositories/supplier_repository.dart';

class GetSuppliers implements UseCase<List<Supplier>, NoParams> {
  final SupplierRepository repository;
  GetSuppliers(this.repository);

  @override
  Future<Result<List<Supplier>>> call(NoParams params) =>
      repository.getSuppliers();
}
