import '../../../../core/error/result.dart';
import '../entities/ai_conversation.dart';

abstract class AiRepository {
  Future<Result<List<AiConversation>>> getConversations();
  Future<Result<AiConversation>> createConversation();
  Future<Result<AiConversation>> getConversationDetail(String id);
  Future<Result<void>> archiveConversation(String id);
  Future<Result<AiResponse>> sendMessage(String id, String content);
  Future<Result<AiAction>> confirmAction(String id, String accionId);
}
