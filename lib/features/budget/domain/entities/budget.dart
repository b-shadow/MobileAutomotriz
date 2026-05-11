import 'package:equatable/equatable.dart';

class BudgetDetail extends Equatable {
  final String id;
  final String? servicioCatalogoId;
  final String descripcion;
  final int cantidad;
  final int tiempoEstandarMin;
  final double precioUnitario;
  final double subtotal;
  final String estado;

  const BudgetDetail({
    required this.id,
    this.servicioCatalogoId,
    required this.descripcion,
    required this.cantidad,
    required this.tiempoEstandarMin,
    required this.precioUnitario,
    required this.subtotal,
    required this.estado,
  });

  @override
  List<Object?> get props => [
        id,
        servicioCatalogoId,
        descripcion,
        cantidad,
        precioUnitario,
        subtotal,
        estado
      ];
}

class Budget extends Equatable {
  final String id;
  final String citaId;
  final String estado;
  final double subtotal;
  final double descuento;
  final double total;
  final String? observaciones;
  final List<BudgetDetail> detalles;
  final DateTime createdAt;

  // Datos extra para vista
  final String? vehiculoPlaca;
  final String? clienteNombre;
  
  // Saldos
  final double saldoPendiente;
  final double porcentajePagado;

  const Budget({
    required this.id,
    required this.citaId,
    required this.estado,
    required this.subtotal,
    required this.descuento,
    required this.total,
    this.observaciones,
    this.detalles = const [],
    required this.createdAt,
    this.vehiculoPlaca,
    this.clienteNombre,
    this.saldoPendiente = 0.0,
    this.porcentajePagado = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        citaId,
        estado,
        subtotal,
        descuento,
        total,
        observaciones,
        detalles,
        createdAt
      ];
}
