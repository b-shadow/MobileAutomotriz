class VehicleHistory {
  final String id;
  final String fecha;
  final String estado;
  final String canal;

  const VehicleHistory({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.canal,
  });
}

class VehicleReportDetail {
  final String placa;
  final String marca;
  final String modelo;
  final int totalVisitas;
  final String ultimaVisita;
  final List<VehicleHistory> historial;

  const VehicleReportDetail({
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.totalVisitas,
    required this.ultimaVisita,
    required this.historial,
  });
}
