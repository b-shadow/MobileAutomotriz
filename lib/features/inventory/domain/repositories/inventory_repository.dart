import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_category.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_item.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_movement.dart';

abstract class InventoryRepository {
  Future<Result<List<InventoryCategory>>> getCategories();

  Future<Result<InventoryCategory>> createCategory({
    required String nombre,
    String? descripcion,
  });

  Future<Result<List<InventoryItem>>> getItems();

  Future<Result<InventoryItem>> createItem({
    required String categoria,
    required String codigo,
    required String nombre,
    String? descripcion,
    required String tipoItem,
    required String unidadMedida,
    int stockActual,
    int stockMinimo,
    double costoPromedio,
    double precioVenta,
  });

  Future<Result<InventoryMovement>> adjustStock({
    required String itemId,
    required String tipoMovimiento,
    required int cantidad,
    int? cantidadAjuste,
    String? observacion,
  });

  Future<Result<List<InventoryMovement>>> getMovements();
}
