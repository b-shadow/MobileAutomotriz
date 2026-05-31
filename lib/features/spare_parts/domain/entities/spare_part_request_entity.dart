import 'package:equatable/equatable.dart';

class SparePartRequestDetail extends Equatable {
  final String id;
  final String? itemInventarioId;
  final String? itemNombre;
  final int cantidadSolicitada;
  final int cantidadAprobada;
  final int cantidadEntregada;
  final int cantidadRecibidaTaller;
  final String estado;
  final String? observacion;
  final DateTime createdAt;

  const SparePartRequestDetail({
    required this.id,
    this.itemInventarioId,
    this.itemNombre,
    required this.cantidadSolicitada,
    required this.cantidadAprobada,
    required this.cantidadEntregada,
    required this.cantidadRecibidaTaller,
    required this.estado,
    this.observacion,
    required this.createdAt,
  });

  bool get pendienteRecibir => cantidadEntregada > cantidadRecibidaTaller;

  @override
  List<Object?> get props => [
        id,
        itemInventarioId,
        itemNombre,
        cantidadSolicitada,
        cantidadAprobada,
        cantidadEntregada,
        cantidadRecibidaTaller,
        estado,
        observacion,
        createdAt,
      ];
}

class SparePartRequestEntity extends Equatable {
  final String id;
  final String? citaId;
  final String? ordenGlobalId;
  final String? solicitadoPor;
  final String? aprobadoPorAsesor;
  final String estado;
  final String? motivo;
  final String? observacionesAsesor;
  final String? observacionesAlmacen;
  final List<SparePartRequestDetail> detalles;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SparePartRequestEntity({
    required this.id,
    this.citaId,
    this.ordenGlobalId,
    this.solicitadoPor,
    this.aprobadoPorAsesor,
    required this.estado,
    this.motivo,
    this.observacionesAsesor,
    this.observacionesAlmacen,
    required this.detalles,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalItems => detalles.length;
  int get totalSolicitado =>
      detalles.fold(0, (sum, d) => sum + d.cantidadSolicitada);
  int get totalEntregado =>
      detalles.fold(0, (sum, d) => sum + d.cantidadEntregada);

  @override
  List<Object?> get props => [
        id,
        citaId,
        ordenGlobalId,
        estado,
        motivo,
        detalles,
        createdAt,
        updatedAt,
      ];
}
