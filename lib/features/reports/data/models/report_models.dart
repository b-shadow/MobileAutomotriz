import '../../domain/entities/report_entities.dart';

class TopVehicleModel extends TopVehicle {
  TopVehicleModel({
    required super.placa,
    required super.vehiculo,
    required super.visitas,
  });

  factory TopVehicleModel.fromJson(Map<String, dynamic> json) {
    return TopVehicleModel(
      placa: json['placa']?.toString() ?? '',
      vehiculo: json['vehiculo']?.toString() ?? '',
      visitas: json['visitas'] as int? ?? 0,
    );
  }
}

class VehicleReportDetailModel extends VehicleReportDetail {
  VehicleReportDetailModel({
    required super.placa,
    required super.marca,
    required super.modelo,
    required super.totalVisitas,
    required super.ultimaVisita,
    required super.historial,
  });

  factory VehicleReportDetailModel.fromJson(Map<String, dynamic> json) {
    final vehiculo = json['vehiculo'] as Map<String, dynamic>? ?? {};
    final kpis = json['kpis'] as Map<String, dynamic>? ?? {};
    final historialJson = json['historial'] as List<dynamic>? ?? [];

    return VehicleReportDetailModel(
      placa: vehiculo['placa']?.toString() ?? '',
      marca: vehiculo['marca']?.toString() ?? '',
      modelo: vehiculo['modelo']?.toString() ?? '',
      totalVisitas: kpis['total_visitas'] as int? ?? 0,
      ultimaVisita: kpis['ultima_visita']?.toString() ?? 'N/A',
      historial: historialJson
          .map((e) => VehicleHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VehicleHistoryModel extends VehicleHistory {
  VehicleHistoryModel({
    required super.id,
    required super.fecha,
    required super.estado,
    required super.canal,
  });

  factory VehicleHistoryModel.fromJson(Map<String, dynamic> json) {
    return VehicleHistoryModel(
      id: json['id']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      canal: json['canal']?.toString() ?? '',
    );
  }
}
