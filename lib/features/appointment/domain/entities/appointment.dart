import 'package:equatable/equatable.dart';

/// Entidad de dominio para una Cita.
class Appointment extends Equatable {
  final String id;
  final String estado;
  final String canalOrigen;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final int duracionEstimadaMin;
  final String? motivoVisita;
  final String? observacionesCliente;
  final String? motivoCancelacion;

  // Vehículo
  final String vehiculoId;
  final String vehiculoPlaca;
  final String vehiculoMarca;
  final String vehiculoModelo;

  // Cliente
  final String? clienteId;
  final String? clienteNombre;
  final String? clienteEmail;

  // Asesor
  final String? asesorNombre;

  // Plan de servicio
  final String? planServicioId;

  // Detalles (servicios)
  final List<AppointmentDetailItem> detalles;

  // Espacios
  final List<AppointmentSegment> espaciosSegmentos;

  // Timestamps
  final DateTime? createdAt;
  final int reprogramacionesCount;

  const Appointment({
    required this.id,
    required this.estado,
    required this.canalOrigen,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.duracionEstimadaMin,
    required this.vehiculoId,
    required this.vehiculoPlaca,
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    this.motivoVisita,
    this.observacionesCliente,
    this.motivoCancelacion,
    this.clienteId,
    this.clienteNombre,
    this.clienteEmail,
    this.asesorNombre,
    this.planServicioId,
    this.detalles = const [],
    this.espaciosSegmentos = const [],
    this.createdAt,
    this.reprogramacionesCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        estado,
        canalOrigen,
        fechaHoraInicio,
        fechaHoraFin,
        vehiculoId,
      ];
}

/// Ítem de detalle dentro de la cita (servicio).
class AppointmentDetailItem extends Equatable {
  final String id;
  final String? servicioNombre;
  final String? servicioCodigo;
  final String estado;
  final int tiempoEstandarMin;
  final double precioReferencial;

  const AppointmentDetailItem({
    required this.id,
    this.servicioNombre,
    this.servicioCodigo,
    required this.estado,
    required this.tiempoEstandarMin,
    required this.precioReferencial,
  });

  @override
  List<Object?> get props => [id];
}

/// Segmento espacio-cita.
class AppointmentSegment extends Equatable {
  final String id;
  final String? espacioNombre;
  final String tipoSegmento;
  final String estadoSegmento;
  final DateTime inicioProgramado;
  final DateTime finProgramado;

  const AppointmentSegment({
    required this.id,
    this.espacioNombre,
    required this.tipoSegmento,
    required this.estadoSegmento,
    required this.inicioProgramado,
    required this.finProgramado,
  });

  @override
  List<Object?> get props => [id];
}
