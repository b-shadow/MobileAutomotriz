import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/usecases/ai_usecases.dart';
import '../../../../core/error/result.dart';

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

  AiChatCubit({
    required this.getAiConversationDetail,
    required this.sendAiMessage,
    required this.confirmAiAction,
  }) : super(AiChatInitial());

  Future<void> fetchDetail(String id) async {
    emit(AiChatLoading());
    final result = await getAiConversationDetail(id);
    switch (result) {
      case Success(:final data):
        emit(AiChatLoaded(conversation: data));
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
}
