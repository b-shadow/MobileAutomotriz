import 'package:equatable/equatable.dart';

class ServiceItem extends Equatable {
  final String id;
  final String nombre;
  final String codigo;
  final double precio;
  final int tiempo;
  final String? descripcion;
  final bool activo;

  const ServiceItem({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.precio,
    required this.tiempo,
    this.descripcion,
    required this.activo,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        codigo,
        precio,
        tiempo,
        descripcion,
        activo,
      ];
}

