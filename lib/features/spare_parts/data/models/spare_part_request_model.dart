import 'package:mobile1_app/features/spare_parts/domain/entities/spare_part_request_entity.dart';

class SparePartRequestDetailModel extends SparePartRequestDetail {
  const SparePartRequestDetailModel({
    required super.id,
    super.itemInventarioId,
    super.itemNombre,
    required super.cantidadSolicitada,
    required super.cantidadAprobada,
    required super.cantidadEntregada,
    required super.cantidadRecibidaTaller,
    required super.estado,
    super.observacion,
    required super.createdAt,
  });

  factory SparePartRequestDetailModel.fromJson(Map<String, dynamic> json) {
    return SparePartRequestDetailModel(
      id: (json['id'] ?? '').toString(),
      itemInventarioId: json['item_inventario']?.toString(),
      itemNombre: json['item_nombre']?.toString(),
      cantidadSolicitada: _parseInt(json['cantidad_solicitada']),
      cantidadAprobada: _parseInt(json['cantidad_aprobada']),
      cantidadEntregada: _parseInt(json['cantidad_entregada']),
      cantidadRecibidaTaller: _parseInt(json['cantidad_recibida_taller']),
      estado: (json['estado'] ?? 'SOLICITADO').toString(),
      observacion: json['observacion']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }
}

class SparePartRequestModel extends SparePartRequestEntity {
  const SparePartRequestModel({
    required super.id,
    super.citaId,
    super.ordenGlobalId,
    super.solicitadoPor,
    super.aprobadoPorAsesor,
    required super.estado,
    super.motivo,
    super.observacionesAsesor,
    super.observacionesAlmacen,
    required super.detalles,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SparePartRequestModel.fromJson(Map<String, dynamic> json) {
    final rawDetalles = json['detalles'];
    final detalles = rawDetalles is List
        ? rawDetalles
            .whereType<Map<String, dynamic>>()
            .map(SparePartRequestDetailModel.fromJson)
            .toList()
        : <SparePartRequestDetail>[];

    return SparePartRequestModel(
      id: (json['id'] ?? '').toString(),
      citaId: json['cita']?.toString(),
      ordenGlobalId: json['orden_global']?.toString(),
      solicitadoPor: json['solicitado_por']?.toString(),
      aprobadoPorAsesor: json['aprobado_por_asesor']?.toString(),
      estado: (json['estado'] ?? 'CREADA').toString(),
      motivo: json['motivo']?.toString(),
      observacionesAsesor: json['observaciones_asesor']?.toString(),
      observacionesAlmacen: json['observaciones_almacen']?.toString(),
      detalles: detalles,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }
}
