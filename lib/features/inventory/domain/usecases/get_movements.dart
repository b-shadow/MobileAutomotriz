import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:mobile1_app/features/inventory/domain/repositories/inventory_repository.dart';

class GetMovements implements UseCase<List<InventoryMovement>, NoParams> {
  final InventoryRepository repository;
  GetMovements(this.repository);

  @override
  Future<Result<List<InventoryMovement>>> call(NoParams params) =>
      repository.getMovements();
}
