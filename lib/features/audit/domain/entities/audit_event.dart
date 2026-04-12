import 'package:equatable/equatable.dart';

class AuditEvent extends Equatable {
  final String id;
  final String usuario;
  final String accion;
  final String entidadTipo;
  final String descripcion;
  final DateTime? createdAt;

  const AuditEvent({
    required this.id,
    required this.usuario,
    required this.accion,
    required this.entidadTipo,
    required this.descripcion,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        usuario,
        accion,
        entidadTipo,
        descripcion,
        createdAt,
      ];
}

