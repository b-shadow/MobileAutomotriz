import 'package:equatable/equatable.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:mobile1_app/features/inventory/domain/repositories/inventory_repository.dart';

class AdjustStockParams extends Equatable {
  final String itemId;
  final String tipoMovimiento;
  final int cantidad;
  final int? cantidadAjuste;
  final String? observacion;

  const AdjustStockParams({
    required this.itemId,
    required this.tipoMovimiento,
    required this.cantidad,
    this.cantidadAjuste,
    this.observacion,
  });

  @override
  List<Object?> get props =>
      [itemId, tipoMovimiento, cantidad, cantidadAjuste, observacion];
}

class AdjustStock implements UseCase<InventoryMovement, AdjustStockParams> {
  final InventoryRepository repository;
  AdjustStock(this.repository);

  @override
  Future<Result<InventoryMovement>> call(AdjustStockParams params) =>
      repository.adjustStock(
        itemId: params.itemId,
        tipoMovimiento: params.tipoMovimiento,
        cantidad: params.cantidad,
        cantidadAjuste: params.cantidadAjuste,
        observacion: params.observacion,
      );
}
