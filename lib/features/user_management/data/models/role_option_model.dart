import 'package:mobile1_app/features/user_management/domain/entities/role_option.dart';

class RoleOptionModel extends RoleOption {
  const RoleOptionModel({
    required super.id,
    required super.nombre,
    required super.descripcion,
  });

  factory RoleOptionModel.fromJson(Map<String, dynamic> json) {
    return RoleOptionModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      nombre: (json['nombre'] ?? json['name'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? json['description']) as String?,
    );
  }
}

