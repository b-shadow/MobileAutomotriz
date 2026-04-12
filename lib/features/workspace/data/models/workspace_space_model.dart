import 'package:mobile1_app/features/workspace/domain/entities/workspace_space.dart';

class WorkspaceSpaceModel extends WorkspaceSpace {
  const WorkspaceSpaceModel({
    required super.id,
    required super.codigo,
    required super.nombre,
    required super.tipo,
    required super.estado,
    required super.activo,
    super.observaciones,
  });

  factory WorkspaceSpaceModel.fromJson(Map<String, dynamic> json) {
    final estadoValue = (json['estado_display'] ?? json['estado'] ?? '').toString();

    return WorkspaceSpaceModel(
      id: (json['id'] ?? '').toString(),
      codigo: (json['codigo'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      tipo: (json['tipo_display'] ?? json['tipo'] ?? '').toString(),
      estado: estadoValue.isEmpty ? 'N/A' : estadoValue,
      activo: json['activo'] as bool? ?? true,
      observaciones: json['observaciones'] as String?,
    );
  }
}

