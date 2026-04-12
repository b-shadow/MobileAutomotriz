import 'package:mobile1_app/features/vehicle/domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.placa,
    required super.marca,
    required super.modelo,
    required super.anio,
    super.color,
    super.kilometraje,
    super.observaciones,
    required super.estado,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final anioRaw = json['anio'] ?? json['año'];
    final kmRaw = json['kilometraje_actual'] ?? json['kilometraje'];

    return VehicleModel(
      id: (json['id'] ?? '').toString(),
      placa: (json['placa'] ?? '').toString(),
      marca: (json['marca'] ?? '').toString(),
      modelo: (json['modelo'] ?? '').toString(),
      anio: anioRaw is int ? anioRaw : int.tryParse('$anioRaw') ?? 0,
      color: json['color'] as String?,
      kilometraje: kmRaw is int ? kmRaw : int.tryParse('$kmRaw'),
      observaciones: json['observaciones'] as String?,
      estado: (json['estado'] ?? 'INACTIVO').toString(),
    );
  }
}



