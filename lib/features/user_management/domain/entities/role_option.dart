import 'package:equatable/equatable.dart';

class RoleOption extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;

  const RoleOption({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion];
}

