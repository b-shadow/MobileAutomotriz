import 'package:equatable/equatable.dart';

class InventoryCategory extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryCategory({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, activo, createdAt, updatedAt];
}
