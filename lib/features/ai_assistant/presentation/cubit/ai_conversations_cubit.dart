import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/usecases/ai_usecases.dart';
import '../../../../core/error/result.dart';

abstract class AiConversationsState extends Equatable {
  const AiConversationsState();
  @override
  List<Object> get props => [];
}

class AiConversationsInitial extends AiConversationsState {}

class AiConversationsLoading extends AiConversationsState {}

class AiConversationsLoaded extends AiConversationsState {
  final List<AiConversation> conversations;
  const AiConversationsLoaded(this.conversations);
  @override
  List<Object> get props => [conversations];
}

class AiConversationsError extends AiConversationsState {
  final String message;
  const AiConversationsError(this.message);
  @override
  List<Object> get props => [message];
}

class AiConversationsCubit extends Cubit<AiConversationsState> {
  final GetAiConversations getAiConversations;
  final CreateAiConversation createAiConversation;
  final ArchiveAiConversation archiveAiConversation;

  AiConversationsCubit({
    required this.getAiConversations,
    required this.createAiConversation,
    required this.archiveAiConversation,
  }) : super(AiConversationsInitial());

  Future<void> fetchConversations() async {
    emit(AiConversationsLoading());
    final result = await getAiConversations();
    switch (result) {
      case Success(:final data):
        emit(AiConversationsLoaded(data));
      case Err(:final failure):
        emit(AiConversationsError(failure.message));
    }
  }

  Future<void> createConversation() async {
    final currentState = state;
    emit(AiConversationsLoading());
    final result = await createAiConversation();
    switch (result) {
      case Success(:final data):
        if (currentState is AiConversationsLoaded) {
          emit(AiConversationsLoaded([data, ...currentState.conversations]));
        } else {
          emit(AiConversationsLoaded([data]));
        }
      case Err(:final failure):
        emit(AiConversationsError(failure.message));
        if (currentState is AiConversationsLoaded) {
          emit(currentState);
        }
    }
  }

  Future<void> archive(String id) async {
    final currentState = state;
    if (currentState is AiConversationsLoaded) {
      final result = await archiveAiConversation(id);
      switch (result) {
        case Success():
          final updatedList = currentState.conversations.where((c) => c.id != id).toList();
          emit(AiConversationsLoaded(updatedList));
        case Err(:final failure):
          emit(AiConversationsError(failure.message));
      }
    }
  }
}
