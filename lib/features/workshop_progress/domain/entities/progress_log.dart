import 'package:equatable/equatable.dart';

class ProgressLog extends Equatable {
  final String id;
  final String citaId;
  final String? ordenDetalleId;
  final String tipo;
  final String estadoNuevo;
  final String mensaje;
  final int porcentajeAvance;
  final bool visibleCliente;
  final String? registradoPor;
  final DateTime createdAt;

  const ProgressLog({
    required this.id,
    required this.citaId,
    this.ordenDetalleId,
    required this.tipo,
    required this.estadoNuevo,
    required this.mensaje,
    required this.porcentajeAvance,
    required this.visibleCliente,
    this.registradoPor,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        citaId,
        ordenDetalleId,
        tipo,
        estadoNuevo,
        mensaje,
        porcentajeAvance,
        visibleCliente,
        registradoPor,
        createdAt,
      ];
}
