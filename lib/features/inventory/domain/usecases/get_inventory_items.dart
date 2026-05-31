import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_item.dart';
import 'package:mobile1_app/features/inventory/domain/repositories/inventory_repository.dart';

class GetInventoryItems implements UseCase<List<InventoryItem>, NoParams> {
  final InventoryRepository repository;
  GetInventoryItems(this.repository);

  @override
  Future<Result<List<InventoryItem>>> call(NoParams params) =>
      repository.getItems();
}
