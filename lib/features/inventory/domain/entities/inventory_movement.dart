import 'package:equatable/equatable.dart';

class InventoryMovement extends Equatable {
  final String id;
  final String? itemInventario;
  final String? itemNombre;
  final String tipoMovimiento;
  final int cantidad;
  final int stockAnterior;
  final int stockPosterior;
  final String? referenciaTipo;
  final String? referenciaId;
  final String? registradoPor;
  final String? observacion;
  final DateTime createdAt;

  const InventoryMovement({
    required this.id,
    this.itemInventario,
    this.itemNombre,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.stockAnterior,
    required this.stockPosterior,
    this.referenciaTipo,
    this.referenciaId,
    this.registradoPor,
    this.observacion,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        itemInventario,
        itemNombre,
        tipoMovimiento,
        cantidad,
        stockAnterior,
        stockPosterior,
        observacion,
        createdAt,
      ];
}
