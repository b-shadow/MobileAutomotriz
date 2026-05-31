import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_category.dart';
import 'package:mobile1_app/features/inventory/domain/repositories/inventory_repository.dart';

class GetCategories implements UseCase<List<InventoryCategory>, NoParams> {
  final InventoryRepository repository;
  GetCategories(this.repository);

  @override
  Future<Result<List<InventoryCategory>>> call(NoParams params) =>
      repository.getCategories();
}
