class VehicleProgress {
  final String id;
  final String vehiculoPlaca;
  final String clienteNombres;
  final String? asesorNombres;
  final String estado;
  final DateTime fechaHoraInicioProgramada;
  final DateTime? llegadaRealAt;
  final DateTime? finalizadaAt;
  final DateTime? vehiculoDevueltoAt;
  final int serviciosCount;
  final Map<String, bool> accionesFlags;

  VehicleProgress({
    required this.id,
    required this.vehiculoPlaca,
    required this.clienteNombres,
    this.asesorNombres,
    required this.estado,
    required this.fechaHoraInicioProgramada,
    this.llegadaRealAt,
    this.finalizadaAt,
    this.vehiculoDevueltoAt,
    required this.serviciosCount,
    required this.accionesFlags,
  });
}
