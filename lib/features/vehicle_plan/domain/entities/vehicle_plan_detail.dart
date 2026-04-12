import 'package:equatable/equatable.dart';

class VehiclePlanDetail extends Equatable {
  final String id;
  final String servicioNombre;
  final String prioridad;
  final String estado;
  final String? observaciones;
  final int? tiempoEstandarMin;
  final double? precioReferencial;

  const VehiclePlanDetail({
    required this.id,
    required this.servicioNombre,
    required this.prioridad,
    required this.estado,
    this.observaciones,
    this.tiempoEstandarMin,
    this.precioReferencial,
  });

  @override
  List<Object?> get props => [
        id,
        servicioNombre,
        prioridad,
        estado,
        observaciones,
        tiempoEstandarMin,
        precioReferencial,
      ];
}

