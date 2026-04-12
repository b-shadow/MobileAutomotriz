import 'package:equatable/equatable.dart';

class Empresa extends Equatable {
  final String id;
  final String nombre;
  final String slug;
  final String estado;
  final String? estadoDisplay;
  final DateTime? suscripcionHasta;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Empresa({
    required this.id,
    required this.nombre,
    required this.slug,
    required this.estado,
    this.estadoDisplay,
    this.suscripcionHasta,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => estado.toUpperCase() == 'ACTIVA';

  @override
  List<Object?> get props => [
        id,
        nombre,
        slug,
        estado,
        estadoDisplay,
        suscripcionHasta,
        createdAt,
        updatedAt,
      ];
}
