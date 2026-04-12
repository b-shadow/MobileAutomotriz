import 'package:equatable/equatable.dart';

class Plan extends Equatable {
  final String id;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final int precioCentavos;
  final int duracionDias;
  final String moneda;
  final bool activo;

  const Plan({
    required this.id,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.precioCentavos,
    required this.duracionDias,
    required this.moneda,
    required this.activo,
  });

  /// Formatted price as a human-readable string (e.g. "\$140.00").
  String get precioFormateado =>
      '\$${(precioCentavos / 100).toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id,
        codigo,
        nombre,
        descripcion,
        precioCentavos,
        duracionDias,
        moneda,
        activo,
      ];
}
