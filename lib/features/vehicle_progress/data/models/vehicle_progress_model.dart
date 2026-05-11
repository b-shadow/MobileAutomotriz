import '../../domain/entities/vehicle_progress.dart';

class VehicleProgressModel extends VehicleProgress {
  VehicleProgressModel({
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
  });

  factory VehicleProgressModel.fromJson(Map<String, dynamic> json) {
    return VehicleProgressModel(
      id: json['id'] as String,
      vehiculoPlaca: json['vehiculo_placa'] as String? ?? 'Desconocida',
      clienteNombres: json['cliente_nombres'] as String? ?? 'Cliente',
      asesorNombres: json['asesor_nombres'] as String?,
      estado: json['estado'] as String,
      fechaHoraInicioProgramada: DateTime.parse(json['fecha_hora_inicio_programada'] as String),
      llegadaRealAt: json['llegada_real_at'] != null ? DateTime.parse(json['llegada_real_at'] as String) : null,
      finalizadaAt: json['finalizada_at'] != null ? DateTime.parse(json['finalizada_at'] as String) : null,
      vehiculoDevueltoAt: json['vehiculo_devuelto_at'] != null ? DateTime.parse(json['vehiculo_devuelto_at'] as String) : null,
      serviciosCount: json['servicios_count'] as int? ?? 0,
      accionesFlags: Map<String, bool>.from(json['acciones_flags'] as Map? ?? {}),
    );
  }
}
