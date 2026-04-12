import 'package:mobile1_app/features/vehicle_plan/domain/entities/vehicle_plan_detail.dart';

class VehiclePlanDetailModel extends VehiclePlanDetail {
  const VehiclePlanDetailModel({
    required super.id,
    required super.servicioNombre,
    required super.prioridad,
    required super.estado,
    super.observaciones,
    super.tiempoEstandarMin,
    super.precioReferencial,
  });

  factory VehiclePlanDetailModel.fromJson(Map<String, dynamic> json) {
    final servicio = json['servicio_catalogo'] is Map<String, dynamic>
        ? json['servicio_catalogo'] as Map<String, dynamic>
        : null;
    final tiempoRaw = json['tiempo_estandar_min'];
    final precioRaw = json['precio_referencial'];

    return VehiclePlanDetailModel(
      id: (json['id'] ?? '').toString(),
      servicioNombre: (json['servicio_nombre'] ??
              servicio?['nombre'] ??
              json['nombre'] ??
              'Servicio')
          .toString(),
      prioridad: (json['prioridad'] ?? 'MEDIA').toString(),
      estado: (json['estado'] ?? 'PENDIENTE').toString(),
      observaciones: json['observaciones'] as String?,
      tiempoEstandarMin: tiempoRaw is int ? tiempoRaw : int.tryParse('$tiempoRaw'),
      precioReferencial: precioRaw is num
          ? precioRaw.toDouble()
          : double.tryParse('$precioRaw'),
    );
  }
}

