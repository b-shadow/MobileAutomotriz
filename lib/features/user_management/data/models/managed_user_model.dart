import 'package:mobile1_app/features/user_management/domain/entities/managed_user.dart';

class ManagedUserModel extends ManagedUser {
  const ManagedUserModel({
    required super.id,
    required super.email,
    required super.nombres,
    required super.apellidos,
    required super.telefono,
    required super.rolId,
    required super.rolNombre,
    required super.activo,
  });

  factory ManagedUserModel.fromJson(Map<String, dynamic> json) {
    final rolRaw = json['rol'];
    final rolId = rolRaw is Map<String, dynamic>
        ? (rolRaw['id'] ?? '').toString()
        : (json['rol_id'] ?? '').toString();
    final rolNombre = rolRaw is Map<String, dynamic>
        ? (rolRaw['nombre'] ?? '').toString()
        : (rolRaw ?? json['rol_nombre'] ?? '').toString();

    return ManagedUserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      nombres: (json['nombres'] ?? '').toString(),
      apellidos: (json['apellidos'] ?? '').toString(),
      telefono: json['telefono'] as String?,
      rolId: rolId,
      rolNombre: rolNombre,
      activo: json['is_active'] as bool? ?? json['activo'] as bool? ?? true,
    );
  }
}

