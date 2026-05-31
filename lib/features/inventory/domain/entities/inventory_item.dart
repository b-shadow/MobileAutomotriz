import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final String id;
  final String? categoria;
  final String? categoriaNombre;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final String tipoItem;
  final String unidadMedida;
  final int stockActual;
  final int stockMinimo;
  final double costoPromedio;
  final double precioVenta;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    this.categoria,
    this.categoriaNombre,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.tipoItem,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    required this.costoPromedio,
    required this.precioVenta,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this item's stock is at or below its minimum threshold.
  bool get isLowStock => stockActual <= stockMinimo;

  @override
  List<Object?> get props => [
        id,
        categoria,
        categoriaNombre,
        codigo,
        nombre,
        descripcion,
        tipoItem,
        unidadMedida,
        stockActual,
        stockMinimo,
        costoPromedio,
        precioVenta,
        activo,
        createdAt,
        updatedAt,
      ];
}
