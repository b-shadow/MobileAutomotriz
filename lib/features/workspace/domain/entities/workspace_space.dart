import 'package:equatable/equatable.dart';

class WorkspaceSpace extends Equatable {
  final String id;
  final String codigo;
  final String nombre;
  final String tipo;
  final String estado;
  final bool activo;
  final String? observaciones;

  const WorkspaceSpace({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.tipo,
    required this.estado,
    required this.activo,
    this.observaciones,
  });

  @override
  List<Object?> get props => [
        id,
        codigo,
        nombre,
        tipo,
        estado,
        activo,
        observaciones,
      ];
}

