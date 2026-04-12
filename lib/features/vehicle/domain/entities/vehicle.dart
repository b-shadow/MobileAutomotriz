import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String placa;
  final String marca;
  final String modelo;
  final int anio;
  final String? color;
  final int? kilometraje;
  final String? observaciones;
  final String estado;

  const Vehicle({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    this.color,
    this.kilometraje,
    this.observaciones,
    required this.estado,
  });

  bool get isActive => estado.toUpperCase() == 'ACTIVO';

  @override
  List<Object?> get props => [
        id,
        placa,
        marca,
        modelo,
        anio,
        color,
        kilometraje,
        observaciones,
        estado,
      ];
}

