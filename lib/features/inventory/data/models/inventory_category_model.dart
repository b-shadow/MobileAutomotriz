import 'package:mobile1_app/features/inventory/domain/entities/inventory_category.dart';

class InventoryCategoryModel extends InventoryCategory {
  const InventoryCategoryModel({
    required super.id,
    required super.nombre,
    super.descripcion,
    required super.activo,
    required super.createdAt,
    required super.updatedAt,
  });

  factory InventoryCategoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryCategoryModel(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: json['descripcion']?.toString(),
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
