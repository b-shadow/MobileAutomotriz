import 'package:mobile1_app/features/inventory/domain/entities/inventory_movement.dart';

class InventoryMovementModel extends InventoryMovement {
  const InventoryMovementModel({
    required super.id,
    super.itemInventario,
    super.itemNombre,
    required super.tipoMovimiento,
    required super.cantidad,
    required super.stockAnterior,
    required super.stockPosterior,
    super.referenciaTipo,
    super.referenciaId,
    super.registradoPor,
    super.observacion,
    required super.createdAt,
  });

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    return InventoryMovementModel(
      id: (json['id'] ?? '').toString(),
      itemInventario: json['item_inventario']?.toString(),
      itemNombre: json['item_nombre']?.toString(),
      tipoMovimiento: (json['tipo_movimiento'] ?? '').toString(),
      cantidad:
          int.tryParse(json['cantidad']?.toString() ?? '0') ?? 0,
      stockAnterior:
          int.tryParse(json['stock_anterior']?.toString() ?? '0') ?? 0,
      stockPosterior:
          int.tryParse(json['stock_posterior']?.toString() ?? '0') ?? 0,
      referenciaTipo: json['referencia_tipo']?.toString(),
      referenciaId: json['referencia_id']?.toString(),
      registradoPor: json['registrado_por']?.toString(),
      observacion: json['observacion']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }
}
