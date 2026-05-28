import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/usecases/ai_usecases.dart';
import '../../../../core/error/result.dart';

import '../../../../core/storage/session_storage.dart';

abstract class AiChatState extends Equatable {
  const AiChatState();
  @override
  List<Object?> get props => [];
}

class AiChatInitial extends AiChatState {}

class AiChatLoading extends AiChatState {}

class AiChatLoaded extends AiChatState {
  final AiConversation conversation;
  final bool isWaitingForAi;
  final List<String> currentSuggestedActions;

  const AiChatLoaded({
    required this.conversation,
    this.isWaitingForAi = false,
    this.currentSuggestedActions = const [],
  });

  AiChatLoaded copyWith({
    AiConversation? conversation,
    bool? isWaitingForAi,
    List<String>? currentSuggestedActions,
  }) {
    return AiChatLoaded(
      conversation: conversation ?? this.conversation,
      isWaitingForAi: isWaitingForAi ?? this.isWaitingForAi,
      currentSuggestedActions: currentSuggestedActions ?? this.currentSuggestedActions,
    );
  }

  @override
  List<Object?> get props => [conversation, isWaitingForAi, currentSuggestedActions];
}

class AiChatError extends AiChatState {
  final String message;
  const AiChatError(this.message);
  @override
  List<Object?> get props => [message];
}

class AiChatCubit extends Cubit<AiChatState> {
  final GetAiConversationDetail getAiConversationDetail;
  final SendAiMessage sendAiMessage;
  final ConfirmAiAction confirmAiAction;
  final TranscribeAiAudio transcribeAiAudio;
  final SessionStorage sessionStorage;
  final ArchiveAiConversation archiveAiConversation;

  AiChatCubit({
    required this.getAiConversationDetail,
    required this.sendAiMessage,
    required this.confirmAiAction,
    required this.transcribeAiAudio,
    required this.sessionStorage,
    required this.archiveAiConversation,
  }) : super(AiChatInitial());

  Future<void> fetchDetail(String id) async {
    emit(AiChatLoading());
    final result = await getAiConversationDetail(id);
    switch (result) {
      case Success(:final data):
        var conversation = data;
        var suggestedActions = <String>[];
        if (conversation.mensajes.isEmpty) {
          final userData = sessionStorage.userData;
          final userName = userData?['nombres'] ?? 'Usuario';
          final welcomeMessage = AiMessage(
            id: 'welcome',
            sender: 'ai',
            text: '¡Hola $userName! Bienvenido al asistente de AutoTaller Pro. Estoy listo para ayudarte con tus tareas diarias.',
            createdAt: DateTime.now(),
          );
          conversation = AiConversation(
            id: conversation.id,
            estado: conversation.estado,
            canal: conversation.canal,
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt,
            numMensajes: 1,
            mensajes: [welcomeMessage],
          );
          suggestedActions = ['¿Qué puedes hacer?', 'Registrar Vehículo', 'Agendar Cita'];
        }
        emit(AiChatLoaded(conversation: conversation, currentSuggestedActions: suggestedActions));
      case Err(:final failure):
        emit(AiChatError(failure.message));
    }
  }

  Future<void> sendMessage(String id, String content) async {
    if (state is! AiChatLoaded) return;
    final currentState = state as AiChatLoaded;

    // Add user message locally for immediate UI update
    final userMessage = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user',
      text: content,
      createdAt: DateTime.now(),
    );
    final updatedConversation = AiConversation(
      id: currentState.conversation.id,
      estado: currentState.conversation.estado,
      canal: currentState.conversation.canal,
      createdAt: currentState.conversation.createdAt,
      updatedAt: DateTime.now(),
      numMensajes: currentState.conversation.numMensajes + 1,
      mensajes: [...currentState.conversation.mensajes, userMessage],
    );

    emit(currentState.copyWith(
      conversation: updatedConversation,
      isWaitingForAi: true,
      currentSuggestedActions: [],
    ));

    final result = await sendAiMessage(id, content);
    switch (result) {
      case Success(:final data):
        final aiMessage = AiMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString() + "_ai",
          sender: 'ai',
          text: data.mensajeIa,
          createdAt: DateTime.now(),
        );

        final finalConversation = AiConversation(
          id: updatedConversation.id,
          estado: updatedConversation.estado,
          canal: updatedConversation.canal,
          createdAt: updatedConversation.createdAt,
          updatedAt: DateTime.now(),
          numMensajes: updatedConversation.numMensajes + 1,
          mensajes: [...updatedConversation.mensajes, aiMessage],
        );

        emit(AiChatLoaded(
          conversation: finalConversation,
          isWaitingForAi: false,
          currentSuggestedActions: data.suggestedActions,
        ));
      case Err(:final failure):
        emit(AiChatError(failure.message));
        emit(currentState);
    }
  }

  Future<void> confirmAction(String conversationId, String accionId) async {
    // Implementación futura si es necesario
    await confirmAiAction(conversationId, accionId);
  }

  Future<void> sendAudioMessage(String conversationId, String audioPath) async {
    if (state is! AiChatLoaded) return;
    final currentState = state as AiChatLoaded;

    emit(currentState.copyWith(isWaitingForAi: true));

    final transcribeResult = await transcribeAiAudio(audioPath);
    switch (transcribeResult) {
      case Success(:final data):
        // If it transcribed successfully but the text is empty, just stop loading
        if (data.trim().isEmpty) {
          emit(currentState.copyWith(isWaitingForAi: false));
          return;
        }
        // Send the transcribed text as a normal message
        await sendMessage(conversationId, data);
      case Err(:final failure):
        emit(AiChatError('Error al transcribir audio: ${failure.message}'));
        emit(currentState.copyWith(isWaitingForAi: false));
    }
  }

  Future<bool> clearChat(String conversationId) async {
    final result = await archiveAiConversation(conversationId);
    switch (result) {
      case Success():
        return true;
      case Err(:final failure):
        emit(AiChatError('Error al limpiar chat: ${failure.message}'));
        return false;
    }
  }
}
