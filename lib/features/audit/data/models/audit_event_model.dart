import 'package:mobile1_app/features/audit/domain/entities/audit_event.dart';

class AuditEventModel extends AuditEvent {
  const AuditEventModel({
    required super.id,
    required super.usuario,
    required super.accion,
    required super.entidadTipo,
    required super.descripcion,
    required super.createdAt,
  });

  factory AuditEventModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return null;
      }
    }

    final usuarioRaw = json['usuario'];
    final usuario = usuarioRaw is Map<String, dynamic>
        ? ((usuarioRaw['email'] ?? usuarioRaw['nombres'] ?? usuarioRaw['id'])
            .toString())
        : (usuarioRaw ?? json['usuario_display'] ?? 'N/A').toString();

    return AuditEventModel(
      id: (json['id'] ?? '').toString(),
      usuario: usuario,
      accion: (json['accion'] ?? '').toString(),
      entidadTipo: (json['entidad_tipo'] ?? json['entidad'] ?? 'N/A').toString(),
      descripcion: (json['descripcion'] ?? json['detalle'] ?? '').toString(),
      createdAt: parseDate(json['created_at'] ?? json['fecha']),
    );
  }
}

