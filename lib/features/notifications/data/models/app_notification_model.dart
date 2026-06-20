import 'package:mobile1_app/features/notifications/domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.tipo,
    required super.titulo,
    required super.mensaje,
    super.entidadTipo,
    super.entidadId,
    required super.leida,
    super.leidaAt,
    super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      entidadTipo: json['entidad_tipo']?.toString(),
      entidadId: json['entidad_id']?.toString(),
      leida: json['leida'] as bool? ?? false,
      leidaAt: json['leida_at'] != null
          ? DateTime.tryParse(json['leida_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
