import '../../../../core/error/result.dart';
import '../entities/ai_conversation.dart';
import '../repositories/ai_repository.dart';

class GetAiConversations {
  final AiRepository repository;
  GetAiConversations(this.repository);
  Future<Result<List<AiConversation>>> call() => repository.getConversations();
}

class CreateAiConversation {
  final AiRepository repository;
  CreateAiConversation(this.repository);
  Future<Result<AiConversation>> call() => repository.createConversation();
}

class GetAiConversationDetail {
  final AiRepository repository;
  GetAiConversationDetail(this.repository);
  Future<Result<AiConversation>> call(String id) => repository.getConversationDetail(id);
}

class ArchiveAiConversation {
  final AiRepository repository;
  ArchiveAiConversation(this.repository);
  Future<Result<void>> call(String id) => repository.archiveConversation(id);
}

class SendAiMessage {
  final AiRepository repository;
  SendAiMessage(this.repository);
  Future<Result<AiResponse>> call(String id, String content) => repository.sendMessage(id, content);
}

class ConfirmAiAction {
  final AiRepository repository;
  ConfirmAiAction(this.repository);
  Future<Result<AiAction>> call(String id, String accionId) => repository.confirmAction(id, accionId);
}
