import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan.dart';

class VehiclePlanModel extends VehiclePlan {
  const VehiclePlanModel({
    required super.id,
    required super.placa,
    required super.marca,
    required super.modelo,
    required super.estado,
    super.descripcionGeneral,
    super.createdAt,
  });

  factory VehiclePlanModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return null;
      }
    }

    final vehiculo = json['vehiculo'] is Map<String, dynamic>
        ? json['vehiculo'] as Map<String, dynamic>
        : null;

    return VehiclePlanModel(
      id: (json['id'] ?? '').toString(),
      placa: (json['placa'] ?? vehiculo?['placa'] ?? '').toString(),
      marca: (json['marca'] ?? vehiculo?['marca'] ?? '').toString(),
      modelo: (json['modelo'] ?? vehiculo?['modelo'] ?? '').toString(),
      estado: (json['estado'] ?? 'LIBRE').toString(),
      descripcionGeneral: json['descripcion_general'] as String?,
      createdAt: parseDate(json['created_at']),
    );
  }
}

