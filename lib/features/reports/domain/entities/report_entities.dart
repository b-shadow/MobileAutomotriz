class TopVehicle {
  final String placa;
  final String vehiculo;
  final int visitas;

  TopVehicle({
    required this.placa,
    required this.vehiculo,
    required this.visitas,
  });
}

class VehicleReportDetail {
  final String placa;
  final String marca;
  final String modelo;
  final int totalVisitas;
  final String ultimaVisita;
  final List<VehicleHistory> historial;

  VehicleReportDetail({
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.totalVisitas,
    required this.ultimaVisita,
    required this.historial,
  });
}

class VehicleHistory {
  final String id;
  final String fecha;
  final String estado;
  final String canal;

  VehicleHistory({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.canal,
  });
}
