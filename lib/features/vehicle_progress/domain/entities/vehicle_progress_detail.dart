import 'vehicle_progress.dart';

class VehicleProgressDetail extends VehicleProgress {
  final String vehiculoMarca;
  final String vehiculoModelo;
  final int duracionEstimadaMin;
  final String? motivoVisita;
  final String? observacionesCliente;
  final List<ServiceDetail> detalles;

  VehicleProgressDetail({
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
    required this.vehiculoMarca,
    required this.vehiculoModelo,
    required this.duracionEstimadaMin,
    this.motivoVisita,
    this.observacionesCliente,
    required this.detalles,
  });
}

class ServiceDetail {
  final String id;
  final String servicioNombre;
  final int tiempoEstandarMin;
  final String estado;

  ServiceDetail({
    required this.id,
    required this.servicioNombre,
    required this.tiempoEstandarMin,
    required this.estado,
  });
}
