/// Representa un ítem de inventario disponible para solicitar.
class InventoryItem {
  final String id;
  final String codigo;
  final String nombre;
  final int stockActual;
  final bool activo;

  const InventoryItem({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.stockActual,
    this.activo = true,
  });

  String get label => '$codigo - $nombre (stock $stockActual)';

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      stockActual: _parseInt(json['stock_actual']),
      activo: json['activo'] == true,
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }
}

/// Detalle de una solicitud de repuesto (un ítem dentro de la solicitud).
class SparePartDetail {
  final String id;
  final String solicitudId;
  final String itemNombre;
  final int cantidadSolicitada;
  final int cantidadEntregada;
  final int cantidadRecibidaTaller;
  final String solicitudEstado;

  const SparePartDetail({
    required this.id,
    required this.solicitudId,
    required this.itemNombre,
    required this.cantidadSolicitada,
    required this.cantidadEntregada,
    required this.cantidadRecibidaTaller,
    required this.solicitudEstado,
  });

  bool get pendienteRecibir => cantidadEntregada > cantidadRecibidaTaller;

  factory SparePartDetail.fromJson(Map<String, dynamic> json, {
    required String solicitudId,
    required String solicitudEstado,
  }) {
    return SparePartDetail(
      id: json['id']?.toString() ?? '',
      solicitudId: solicitudId,
      itemNombre: json['item_nombre']?.toString() ?? json['nombre']?.toString() ?? '',
      cantidadSolicitada: _parseInt(json['cantidad_solicitada']),
      cantidadEntregada: _parseInt(json['cantidad_entregada']),
      cantidadRecibidaTaller: _parseInt(json['cantidad_recibida_taller']),
      solicitudEstado: solicitudEstado,
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }
}

/// Solicitud de repuestos para una orden de trabajo.
class SparePartRequest {
  final String id;
  final String estado;
  final String motivo;
  final String ordenGlobalId;
  final List<SparePartDetail> detalles;

  const SparePartRequest({
    required this.id,
    required this.estado,
    required this.motivo,
    required this.ordenGlobalId,
    required this.detalles,
  });

  factory SparePartRequest.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final estado = json['estado']?.toString() ?? '';
    final rawDetalles = json['detalles'];
    final detalles = rawDetalles is List
        ? rawDetalles
            .whereType<Map<String, dynamic>>()
            .map((d) => SparePartDetail.fromJson(d, solicitudId: id, solicitudEstado: estado))
            .toList()
        : <SparePartDetail>[];

    return SparePartRequest(
      id: id,
      estado: estado,
      motivo: json['motivo']?.toString() ?? '',
      ordenGlobalId: json['orden_global']?.toString() ?? '',
      detalles: detalles,
    );
  }
}

/// Línea para crear una solicitud de repuesto (input).
class SparePartRequestLine {
  String itemInventarioId;
  int cantidadSolicitada;
  String observacion;

  SparePartRequestLine({
    this.itemInventarioId = '',
    this.cantidadSolicitada = 1,
    this.observacion = '',
  });

  SparePartRequestLine copyWith({
    String? itemInventarioId,
    int? cantidadSolicitada,
    String? observacion,
  }) =>
      SparePartRequestLine(
        itemInventarioId: itemInventarioId ?? this.itemInventarioId,
        cantidadSolicitada: cantidadSolicitada ?? this.cantidadSolicitada,
        observacion: observacion ?? this.observacion,
      );
}
