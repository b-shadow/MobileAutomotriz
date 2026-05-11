import '../../domain/entities/vehicle_progress_detail.dart';

class VehicleProgressDetailModel extends VehicleProgressDetail {
  VehicleProgressDetailModel({
    required super.id,
    required super.vehiculoPlaca,
    required super.clienteNombres,
    super.asesorNombres,
    required super.estado,
    required super.fechaHoraInicioProgramada,
    super.llegadaRealAt,
    super.finalizadaAt,
    super.vehiculoDevueltoAt,
    required super.serviciosCount,
    required super.accionesFlags,
    required super.vehiculoMarca,
    required super.vehiculoModelo,
    required super.duracionEstimadaMin,
    super.motivoVisita,
    super.observacionesCliente,
    required super.detalles,
  });

  factory VehicleProgressDetailModel.fromJson(Map<String, dynamic> json) {
    final vehiculo = json['vehiculo'] as Map<String, dynamic>? ?? {};
    final cliente = json['cliente'] as Map<String, dynamic>? ?? {};
    final asesor = json['asesor_responsable'] as Map<String, dynamic>?;
    final detallesList = json['detalles'] as List? ?? [];

    return VehicleProgressDetailModel(
      id: json['id'] as String,
      vehiculoPlaca: vehiculo['placa'] as String? ?? 'Desconocida',
      clienteNombres: cliente['nombres'] as String? ?? 'Cliente',
      asesorNombres: asesor?['nombres'] as String?,
      estado: json['estado'] as String,
      fechaHoraInicioProgramada: DateTime.parse(json['fecha_hora_inicio_programada'] as String),
      llegadaRealAt: json['llegada_real_at'] != null ? DateTime.parse(json['llegada_real_at'] as String) : null,
      finalizadaAt: json['finalizada_at'] != null ? DateTime.parse(json['finalizada_at'] as String) : null,
      vehiculoDevueltoAt: json['vehiculo_devuelto_at'] != null ? DateTime.parse(json['vehiculo_devuelto_at'] as String) : null,
      serviciosCount: detallesList.length,
      accionesFlags: Map<String, bool>.from(json['acciones_flags'] as Map? ?? {}),
      vehiculoMarca: vehiculo['marca'] as String? ?? '',
      vehiculoModelo: vehiculo['modelo'] as String? ?? '',
      duracionEstimadaMin: json['duracion_estimada_min'] as int? ?? 0,
      motivoVisita: json['motivo_visita'] as String?,
      observacionesCliente: json['observaciones_cliente'] as String?,
      detalles: detallesList.map((e) => ServiceDetailModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ServiceDetailModel extends ServiceDetail {
  ServiceDetailModel({
    required super.id,
    required super.servicioNombre,
    required super.tiempoEstandarMin,
    required super.estado,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailModel(
      id: json['id'] as String,
      servicioNombre: json['servicio_nombre'] as String? ?? 'Servicio',
      tiempoEstandarMin: json['tiempo_estandar_min'] as int? ?? 0,
      estado: json['estado'] as String? ?? '',
    );
  }
}
