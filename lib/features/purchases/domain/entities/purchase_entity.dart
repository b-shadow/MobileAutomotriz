import 'package:equatable/equatable.dart';

class PurchaseDetail extends Equatable {
  final String id;
  final String? itemInventarioId;
  final String? itemNombre;
  final int cantidad;
  final double costoUnitario;
  final double subtotal;

  const PurchaseDetail({
    required this.id,
    this.itemInventarioId,
    this.itemNombre,
    required this.cantidad,
    required this.costoUnitario,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
        id,
        itemInventarioId,
        itemNombre,
        cantidad,
        costoUnitario,
        subtotal,
      ];
}

class Purchase extends Equatable {
  final String id;
  final String? proveedorId;
  final String? proveedorNombre;
  final String numeroDocumento;
  final String estado;
  final DateTime fechaCompra;
  final double subtotal;
  final double total;
  final String? observaciones;
  final List<PurchaseDetail> detalles;
  final DateTime createdAt;

  const Purchase({
    required this.id,
    this.proveedorId,
    this.proveedorNombre,
    required this.numeroDocumento,
    required this.estado,
    required this.fechaCompra,
    required this.subtotal,
    required this.total,
    this.observaciones,
    this.detalles = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        proveedorId,
        proveedorNombre,
        numeroDocumento,
        estado,
        fechaCompra,
        subtotal,
        total,
        observaciones,
        detalles,
        createdAt,
      ];
}

class PurchaseInput {
  final String proveedorId;
  final String numeroDocumento;
  final DateTime fechaCompra;
  final String? observaciones;
  final List<PurchaseDetailInput> detalles;

  const PurchaseInput({
    required this.proveedorId,
    required this.numeroDocumento,
    required this.fechaCompra,
    this.observaciones,
    required this.detalles,
  });

  Map<String, dynamic> toJson() => {
        'proveedor_id': proveedorId,
        'numero_documento': numeroDocumento,
        'fecha_compra': "${fechaCompra.year}-${fechaCompra.month.toString().padLeft(2, '0')}-${fechaCompra.day.toString().padLeft(2, '0')}",
        'observaciones': observaciones,
        'detalles': detalles.map((d) => d.toJson()).toList(),
      };
}

class PurchaseDetailInput {
  final String itemInventarioId;
  final int cantidad;
  final double costoUnitario;

  const PurchaseDetailInput({
    required this.itemInventarioId,
    required this.cantidad,
    required this.costoUnitario,
  });

  Map<String, dynamic> toJson() => {
        'item_inventario_id': itemInventarioId,
        'cantidad': cantidad,
        'costo_unitario': costoUnitario,
      };
}
