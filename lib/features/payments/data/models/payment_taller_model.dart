import 'package:mobile1_app/features/payments/domain/entities/payment_taller_entity.dart';

class PaymentTallerModel extends PaymentTallerEntity {
  const PaymentTallerModel({
    required super.id,
    super.codigoPago,
    required super.tipoOrigen,
    super.origenDisplay,
    super.citaId,
    super.ventaId,
    required super.estado,
    required super.montoTotal,
    required super.montoReal,
    required super.montoCobrado,
    super.montoPagado,
    required super.metodoPago,
    required super.moneda,
    super.referencia,
    super.descripcion,
    super.fechaPago,
    super.recibidoAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PaymentTallerModel.fromJson(Map<String, dynamic> json) {
    return PaymentTallerModel(
      id: (json['id'] ?? '').toString(),
      codigoPago: json['codigo_pago']?.toString(),
      tipoOrigen: (json['tipo_origen'] ?? 'VENTA').toString(),
      origenDisplay: json['origen_display']?.toString(),
      citaId: json['cita']?.toString(),
      ventaId: json['venta']?.toString(),
      estado: (json['estado'] ?? 'PENDIENTE').toString(),
      montoTotal: _parseDouble(json['monto_total']),
      montoReal: _parseDouble(json['monto_real']),
      montoCobrado: _parseDouble(json['monto_cobrado']),
      montoPagado: json['monto_pagado'] != null
          ? _parseDouble(json['monto_pagado'])
          : null,
      metodoPago: (json['metodo_pago'] ?? '').toString(),
      moneda: (json['moneda'] ?? 'BOB').toString(),
      referencia: json['referencia']?.toString(),
      descripcion: json['descripcion']?.toString(),
      fechaPago: json['fecha_pago'] != null
          ? DateTime.tryParse(json['fecha_pago'].toString())
          : null,
      recibidoAt: json['recibido_at'] != null
          ? DateTime.tryParse(json['recibido_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }
}
