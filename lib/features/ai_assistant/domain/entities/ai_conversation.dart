class AiConversation {
  final String id;
  final String estado;
  final String canal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int numMensajes;
  final List<AiMessage> mensajes;

  AiConversation({
    required this.id,
    required this.estado,
    required this.canal,
    required this.createdAt,
    required this.updatedAt,
    required this.numMensajes,
    this.mensajes = const [],
  });
}

class AiMessage {
  final String id;
  final String sender; // 'user' or 'ai'
  final String text;
  final DateTime createdAt;

  AiMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });
}

class AiAction {
  final String id;
  final String accion;
  final Map<String, dynamic> parametros;
  final String estado;
  final bool requiereConfirmacion;
  final Map<String, dynamic>? resultado;

  AiAction({
    required this.id,
    required this.accion,
    required this.parametros,
    required this.estado,
    required this.requiereConfirmacion,
    this.resultado,
  });
}

class AiResponse {
  final String mensajeIa;
  final AiAction? accion;
  final List<String> suggestedActions;
  final List<String> options;
  final String currentConversationId;

  AiResponse({
    required this.mensajeIa,
    this.accion,
    this.suggestedActions = const [],
    this.options = const [],
    required this.currentConversationId,
  });
}
