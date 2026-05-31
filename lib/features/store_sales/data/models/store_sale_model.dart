import 'package:mobile1_app/features/store_sales/domain/entities/store_sale_entity.dart';

class StoreSaleDetailModel extends StoreSaleDetail {
  const StoreSaleDetailModel({
    required super.id,
    super.itemInventarioId,
    super.itemNombre,
    required super.cantidad,
    required super.precioUnitario,
    required super.subtotal,
  });

  factory StoreSaleDetailModel.fromJson(Map<String, dynamic> json) {
    return StoreSaleDetailModel(
      id: (json['id'] ?? '').toString(),
      itemInventarioId: json['item_inventario']?.toString(),
      itemNombre: json['item_nombre']?.toString() ?? json['item_inventario_nombre']?.toString(),
      cantidad: _parseInt(json['cantidad']),
      precioUnitario: _parseDouble(json['precio_unitario']),
      subtotal: _parseDouble(json['subtotal']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '0') ?? 0.0;
  }
}

class StoreSaleModel extends StoreSale {
  const StoreSaleModel({
    required super.id,
    super.clienteNombreLibre,
    super.clienteDocumento,
    required super.estado,
    required super.subtotal,
    required super.total,
    required super.detalles,
    required super.createdAt,
  });

  factory StoreSaleModel.fromJson(Map<String, dynamic> json) {
    final rawDetalles = json['detalles'];
    final detalles = rawDetalles is List
        ? rawDetalles
            .whereType<Map<String, dynamic>>()
            .map(StoreSaleDetailModel.fromJson)
            .toList()
        : <StoreSaleDetailModel>[];

    return StoreSaleModel(
      id: (json['id'] ?? '').toString(),
      clienteNombreLibre: json['cliente_nombre_libre']?.toString(),
      clienteDocumento: json['cliente_documento']?.toString(),
      estado: (json['estado'] ?? 'BORRADOR').toString(),
      subtotal: StoreSaleDetailModel._parseDouble(json['subtotal']),
      total: StoreSaleDetailModel._parseDouble(json['total']),
      detalles: detalles,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
