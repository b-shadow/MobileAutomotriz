import 'package:mobile1_app/features/budget/domain/entities/budget.dart';

class BudgetDetailModel extends BudgetDetail {
  const BudgetDetailModel({
    required super.id,
    super.servicioCatalogoId,
    required super.descripcion,
    required super.cantidad,
    required super.tiempoEstandarMin,
    required super.precioUnitario,
    required super.subtotal,
    required super.estado,
  });

  factory BudgetDetailModel.fromJson(Map<String, dynamic> json) {
    return BudgetDetailModel(
      id: (json['id'] ?? '').toString(),
      servicioCatalogoId: json['servicio_catalogo']?.toString(),
      descripcion: (json['servicio_nombre'] ?? json['descripcion'] ?? 'Servicio').toString(),
      cantidad: int.tryParse(json['cantidad']?.toString() ?? '1') ?? 1,
      tiempoEstandarMin: int.tryParse(json['tiempo_estandar_min']?.toString() ?? '0') ?? 0,
      precioUnitario: double.tryParse(json['precio_unitario']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      estado: (json['estado'] ?? 'ACTIVO').toString(),
    );
  }
}

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.citaId,
    required super.estado,
    required super.subtotal,
    required super.descuento,
    required super.total,
    super.observaciones,
    super.detalles,
    required super.createdAt,
    super.vehiculoPlaca,
    super.clienteNombre,
    super.saldoPendiente,
    super.porcentajePagado,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final detallesList = json['detalles'] as List?;
    final List<BudgetDetailModel> parsedDetalles = detallesList != null
        ? detallesList
            .whereType<Map<String, dynamic>>()
            .map((e) => BudgetDetailModel.fromJson(e))
            .toList()
        : [];

    return BudgetModel(
      id: (json['id'] ?? '').toString(),
      citaId: (json['cita'] ?? '').toString(),
      estado: (json['estado'] ?? 'BORRADOR').toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      descuento: double.tryParse(json['descuento']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      observaciones: json['observaciones']?.toString(),
      detalles: parsedDetalles,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      // Datos extraídos del serializer nested si es que el backend los envía (PresupuestoCita no los tiene directos pero podemos sacarlos si vinieran o ignorarlos si tenemos la info de cita)
      saldoPendiente: double.tryParse(json['saldo_pendiente']?.toString() ?? '0') ?? 0.0,
      porcentajePagado: double.tryParse(json['porcentaje_pagado']?.toString() ?? '0') ?? 0.0,
    );
  }
}
