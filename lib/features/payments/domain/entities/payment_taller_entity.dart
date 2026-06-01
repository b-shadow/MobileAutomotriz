import 'package:equatable/equatable.dart';

class PaymentTallerEntity extends Equatable {
  final String id;
  final String? codigoPago;
  final String tipoOrigen;
  final String? origenDisplay;
  final String? citaId;
  final String? ventaId;
  final String estado;
  final double montoTotal;
  final double montoReal;
  final double montoCobrado;
  final double? montoPagado;
  final String metodoPago;
  final String moneda;
  final String? referencia;
  final String? descripcion;
  final DateTime? fechaPago;
  final DateTime? recibidoAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentTallerEntity({
    required this.id,
    this.codigoPago,
    required this.tipoOrigen,
    this.origenDisplay,
    this.citaId,
    this.ventaId,
    required this.estado,
    required this.montoTotal,
    required this.montoReal,
    required this.montoCobrado,
    this.montoPagado,
    required this.metodoPago,
    required this.moneda,
    this.referencia,
    this.descripcion,
    this.fechaPago,
    this.recibidoAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPendiente => estado == 'PENDIENTE';
  bool get isConfirmado => estado == 'CONFIRMADO';
  bool get isRecibido => estado == 'RECIBIDO';
  bool get canMarkReceived => isPendiente;

  String get estadoLabel => switch (estado) {
        'PENDIENTE' => 'Pendiente',
        'CONFIRMADO' => 'Confirmado',
        'RECIBIDO' => 'Recibido',
        'FACTURADO' => 'Facturado',
        'ANULADO' => 'Anulado',
        'CANCELADO' => 'Cancelado',
        'VENCIDO' => 'Vencido',
        'RECHAZADO' => 'Rechazado',
        'MONTO_INCORRECTO' => 'Monto Incorrecto',
        _ => estado,
      };

  @override
  List<Object?> get props => [id, estado, montoTotal, metodoPago, createdAt];
}
