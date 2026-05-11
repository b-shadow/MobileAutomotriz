import '../../domain/entities/ai_conversation.dart';

class AiConversationModel extends AiConversation {
  AiConversationModel({
    required super.id,
    required super.estado,
    required super.canal,
    required super.createdAt,
    required super.updatedAt,
    required super.numMensajes,
    super.mensajes,
  });

  factory AiConversationModel.fromJson(Map<String, dynamic> json) {
    return AiConversationModel(
      id: json['id']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'ACTIVA',
      canal: json['canal']?.toString() ?? 'WEB',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'].toString()) : DateTime.now(),
      numMensajes: json['num_mensajes'] as int? ?? 0,
      mensajes: (json['mensajes'] as List?)
              ?.map((e) => AiMessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }
}

class AiMessageModel extends AiMessage {
  AiMessageModel({
    required super.id,
    required super.sender,
    required super.text,
    required super.createdAt,
  });

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    return AiMessageModel(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? 'user',
      text: json['text']?.toString() ?? json['contenido']?.toString() ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
    );
  }
}

class AiActionModel extends AiAction {
  AiActionModel({
    required super.id,
    required super.accion,
    required super.parametros,
    required super.estado,
    required super.requiereConfirmacion,
    super.resultado,
  });

  factory AiActionModel.fromJson(Map<String, dynamic> json) {
    return AiActionModel(
      id: json['id']?.toString() ?? '',
      accion: json['accion']?.toString() ?? '',
      parametros: json['parametros'] != null ? Map<String, dynamic>.from(json['parametros'] as Map) : {},
      estado: json['estado']?.toString() ?? 'PENDIENTE',
      requiereConfirmacion: json['requiere_confirmacion'] == true,
      resultado: json['resultado'] != null ? Map<String, dynamic>.from(json['resultado'] as Map) : null,
    );
  }
}

class AiResponseModel extends AiResponse {
  AiResponseModel({
    required super.mensajeIa,
    super.accion,
    super.suggestedActions,
    super.options,
    required super.currentConversationId,
  });

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    return AiResponseModel(
      mensajeIa: json['mensaje_ia']?.toString() ?? '',
      accion: json['accion'] != null
          ? AiActionModel.fromJson(Map<String, dynamic>.from(json['accion'] as Map))
          : null,
      suggestedActions: (json['suggested_actions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      currentConversationId: json['current_conversation_id']?.toString() ?? '',
    );
  }
}
