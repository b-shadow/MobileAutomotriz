import 'package:mobile1_app/features/inventory/domain/entities/inventory_item.dart';

class InventoryItemModel extends InventoryItem {
  const InventoryItemModel({
    required super.id,
    super.categoria,
    super.categoriaNombre,
    required super.codigo,
    required super.nombre,
    super.descripcion,
    required super.tipoItem,
    required super.unidadMedida,
    required super.stockActual,
    required super.stockMinimo,
    required super.costoPromedio,
    required super.precioVenta,
    required super.activo,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: (json['id'] ?? '').toString(),
      categoria: json['categoria']?.toString(),
      categoriaNombre: json['categoria_nombre']?.toString(),
      codigo: (json['codigo'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: json['descripcion']?.toString(),
      tipoItem: (json['tipo_item'] ?? 'REPUESTO').toString(),
      unidadMedida: (json['unidad_medida'] ?? 'pieza').toString(),
      stockActual:
          int.tryParse(json['stock_actual']?.toString() ?? '0') ?? 0,
      stockMinimo:
          int.tryParse(json['stock_minimo']?.toString() ?? '0') ?? 0,
      costoPromedio:
          double.tryParse(json['costo_promedio']?.toString() ?? '0') ?? 0.0,
      precioVenta:
          double.tryParse(json['precio_venta']?.toString() ?? '0') ?? 0.0,
      activo: json['activo'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }
}
