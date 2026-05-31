import 'package:mobile1_app/features/purchases/domain/entities/purchase_entity.dart';

class PurchaseDetailModel extends PurchaseDetail {
  const PurchaseDetailModel({
    required super.id,
    super.itemInventarioId,
    super.itemNombre,
    required super.cantidad,
    required super.costoUnitario,
    required super.subtotal,
  });

  factory PurchaseDetailModel.fromJson(Map<String, dynamic> json) {
    return PurchaseDetailModel(
      id: (json['id'] ?? '').toString(),
      itemInventarioId: json['item_inventario']?.toString(),
      itemNombre: json['item_nombre']?.toString() ?? json['item_inventario_nombre']?.toString(),
      cantidad: _parseInt(json['cantidad']),
      costoUnitario: _parseDouble(json['costo_unitario']),
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

class PurchaseModel extends Purchase {
  const PurchaseModel({
    required super.id,
    super.proveedorId,
    super.proveedorNombre,
    required super.numeroDocumento,
    required super.estado,
    required super.fechaCompra,
    required super.subtotal,
    required super.total,
    super.observaciones,
    required super.detalles,
    required super.createdAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    final rawDetalles = json['detalles'];
    final detalles = rawDetalles is List
        ? rawDetalles
            .whereType<Map<String, dynamic>>()
            .map(PurchaseDetailModel.fromJson)
            .toList()
        : <PurchaseDetailModel>[];

    return PurchaseModel(
      id: (json['id'] ?? '').toString(),
      proveedorId: json['proveedor']?.toString() ?? json['proveedor_id']?.toString(),
      proveedorNombre: json['proveedor_nombre']?.toString(),
      numeroDocumento: (json['numero_documento'] ?? '').toString(),
      estado: (json['estado'] ?? 'BORRADOR').toString(),
      fechaCompra: json['fecha_compra'] != null
          ? DateTime.tryParse(json['fecha_compra'].toString()) ?? DateTime.now()
          : DateTime.now(),
      subtotal: PurchaseDetailModel._parseDouble(json['subtotal']),
      total: PurchaseDetailModel._parseDouble(json['total']),
      observaciones: json['observaciones']?.toString(),
      detalles: detalles,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
