import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String tipo;
  final String titulo;
  final String mensaje;
  final String? entidadTipo;
  final String? entidadId;
  final bool leida;
  final DateTime? leidaAt;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    this.entidadTipo,
    this.entidadId,
    required this.leida,
    this.leidaAt,
    this.createdAt,
  });

  AppNotification copyWith({
    bool? leida,
    DateTime? leidaAt,
  }) {
    return AppNotification(
      id: id,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      entidadTipo: entidadTipo,
      entidadId: entidadId,
      leida: leida ?? this.leida,
      leidaAt: leidaAt ?? this.leidaAt,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tipo,
        titulo,
        mensaje,
        entidadTipo,
        entidadId,
        leida,
        leidaAt,
        createdAt,
      ];
}
