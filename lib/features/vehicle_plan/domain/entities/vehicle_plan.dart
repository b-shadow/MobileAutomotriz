import 'package:equatable/equatable.dart';

class VehiclePlan extends Equatable {
  final String id;
  final String placa;
  final String marca;
  final String modelo;
  final String estado;
  final String? descripcionGeneral;
  final DateTime? createdAt;

  const VehiclePlan({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.estado,
    this.descripcionGeneral,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        placa,
        marca,
        modelo,
        estado,
        descripcionGeneral,
        createdAt,
      ];
}

