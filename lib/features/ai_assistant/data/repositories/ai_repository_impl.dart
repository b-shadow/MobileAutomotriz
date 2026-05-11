import '../../../../core/network/network_info.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ai_conversation.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_data_source.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AiRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<AiConversation>>> getConversations() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.getConversations();
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AiConversation>> createConversation() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.createConversation();
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AiConversation>> getConversationDetail(String id) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.getConversationDetail(id);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> archiveConversation(String id) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      await remoteDataSource.archiveConversation(id);
      return const Success(null);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AiResponse>> sendMessage(String id, String content) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.sendMessage(id, content);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<AiAction>> confirmAction(String id, String accionId) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    try {
      final data = await remoteDataSource.confirmAction(id, accionId);
      return Success(data);
    } catch (e) {
      return Err(ServerFailure(message: e.toString()));
    }
  }
}
