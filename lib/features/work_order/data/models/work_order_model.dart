import 'package:mobile1_app/features/work_order/domain/entities/work_order.dart';

class MechanicModel extends Mechanic {
  const MechanicModel({
    required super.id,
    required super.nombre,
    required super.email,
  });

  factory MechanicModel.fromJson(Map<String, dynamic> json) {
    return MechanicModel(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}

class WorkOrderMechanicModel extends WorkOrderMechanic {
  const WorkOrderMechanicModel({
    required super.id,
    required super.mecanico,
    required super.mecanicoNombres,
    required super.esPrincipal,
  });

  factory WorkOrderMechanicModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderMechanicModel(
      id: (json['id'] ?? '').toString(),
      mecanico: (json['mecanico'] ?? '').toString(),
      mecanicoNombres: (json['mecanico_nombres'] ?? 'Mecánico').toString(),
      esPrincipal: json['es_principal'] == true,
    );
  }
}

class WorkOrderDetailModel extends WorkOrderDetail {
  const WorkOrderDetailModel({
    required super.id,
    super.servicioCatalogo,
    required super.servicioNombre,
    required super.estado,
    required super.tiempoEstandarMin,
    required super.tiempoRealMin,
    super.mecanicoAsignado,
    super.mecanicoNombres,
  });

  factory WorkOrderDetailModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderDetailModel(
      id: (json['id'] ?? '').toString(),
      servicioCatalogo: json['servicio_catalogo']?.toString(),
      servicioNombre: (json['servicio_nombre'] ?? 'Servicio').toString(),
      estado: (json['estado'] ?? 'POR_HACER').toString(),
      tiempoEstandarMin: int.tryParse(json['tiempo_estandar_min']?.toString() ?? '0') ?? 0,
      tiempoRealMin: int.tryParse(json['tiempo_real_min']?.toString() ?? '0') ?? 0,
      mecanicoAsignado: json['mecanico_asignado']?.toString(),
      mecanicoNombres: json['mecanico_nombres']?.toString(),
    );
  }
}

class WorkOrderModel extends WorkOrder {
  const WorkOrderModel({
    required super.id,
    required super.citaId,
    required super.numero,
    required super.estado,
    super.observaciones,
    required super.fechaApertura,
    super.fechaCierre,
    super.detalles,
    super.mecanicosAsignados,
    super.vehiculoPlaca,
    super.clienteNombre,
  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    final detallesList = json['detalles'] as List?;
    final parsedDetalles = detallesList != null
        ? detallesList
            .whereType<Map<String, dynamic>>()
            .map((e) => WorkOrderDetailModel.fromJson(e))
            .toList()
        : const <WorkOrderDetailModel>[];

    final mecanicosList = json['mecanicos_asignados'] as List?;
    final parsedMecanicos = mecanicosList != null
        ? mecanicosList
            .whereType<Map<String, dynamic>>()
            .map((e) => WorkOrderMechanicModel.fromJson(e))
            .toList()
        : const <WorkOrderMechanicModel>[];

    return WorkOrderModel(
      id: (json['id'] ?? '').toString(),
      citaId: (json['cita'] ?? '').toString(),
      numero: (json['numero'] ?? '').toString(),
      estado: (json['estado'] ?? 'ABIERTA').toString(),
      observaciones: json['observaciones']?.toString(),
      fechaApertura: json['fecha_apertura'] != null
          ? DateTime.parse(json['fecha_apertura'].toString())
          : DateTime.now(),
      fechaCierre: json['fecha_cierre'] != null
          ? DateTime.parse(json['fecha_cierre'].toString())
          : null,
      detalles: parsedDetalles,
      mecanicosAsignados: parsedMecanicos,
      // Aunque el serializer global básico no traiga placa ni cliente, 
      // si usamos el mismo modelo del backend o lo unimos, se prevé el campo.
      vehiculoPlaca: json['cita__vehiculo__placa']?.toString(),
      clienteNombre: json['cita__cliente__nombres']?.toString(),
    );
  }
}
