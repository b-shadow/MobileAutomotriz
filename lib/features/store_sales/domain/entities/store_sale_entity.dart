import 'package:equatable/equatable.dart';

class StoreSaleDetail extends Equatable {
  final String id;
  final String? itemInventarioId;
  final String? itemNombre;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  const StoreSaleDetail({
    required this.id,
    this.itemInventarioId,
    this.itemNombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
        id,
        itemInventarioId,
        itemNombre,
        cantidad,
        precioUnitario,
        subtotal,
      ];
}

class StoreSale extends Equatable {
  final String id;
  final String? clienteNombreLibre;
  final String? clienteDocumento;
  final String estado;
  final double subtotal;
  final double total;
  final List<StoreSaleDetail> detalles;
  final DateTime createdAt;

  const StoreSale({
    required this.id,
    this.clienteNombreLibre,
    this.clienteDocumento,
    required this.estado,
    required this.subtotal,
    required this.total,
    this.detalles = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        clienteNombreLibre,
        clienteDocumento,
        estado,
        subtotal,
        total,
        detalles,
        createdAt,
      ];
}

class StoreSaleInput {
  final String? clienteNombreLibre;
  final String? clienteDocumento;
  final List<StoreSaleDetailInput> detalles;

  const StoreSaleInput({
    this.clienteNombreLibre,
    this.clienteDocumento,
    required this.detalles,
  });

  Map<String, dynamic> toJson() => {
        'cliente_nombre_libre': clienteNombreLibre,
        'cliente_documento': clienteDocumento,
        'detalles': detalles.map((d) => d.toJson()).toList(),
      };
}

class StoreSaleDetailInput {
  final String itemInventarioId;
  final int cantidad;
  final double precioUnitario;

  const StoreSaleDetailInput({
    required this.itemInventarioId,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toJson() => {
        'item_inventario_id': itemInventarioId,
        'cantidad': cantidad,
        'precio_unitario': precioUnitario,
      };
}
