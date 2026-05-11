import '../../../../core/network/api_client.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/ai_models.dart';

abstract class AiRemoteDataSource {
  Future<List<AiConversationModel>> getConversations();
  Future<AiConversationModel> createConversation();
  Future<AiConversationModel> getConversationDetail(String id);
  Future<void> archiveConversation(String id);
  Future<AiResponseModel> sendMessage(String id, String content);
  Future<AiActionModel> confirmAction(String id, String accionId);
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  AiRemoteDataSourceImpl({required this.apiClient, required this.sessionStorage});

  Future<String> _getTenantSlug() async {
    final userData = sessionStorage.userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      return tenant['slug'] as String? ?? '';
    }
    throw Exception('No tenant found in session');
  }

  @override
  Future<List<AiConversationModel>> getConversations() async {
    final slug = await _getTenantSlug();
    final url = ApiConstants.iaConversaciones(slug);
    final response = await apiClient.get(url);
    final List<dynamic> data = response.data is List ? response.data : response.data['results'] ?? [];
    return data.map((e) => AiConversationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<AiConversationModel> createConversation() async {
    final slug = await _getTenantSlug();
    final url = ApiConstants.iaConversaciones(slug);
    final response = await apiClient.post(url, data: {});
    return AiConversationModel.fromJson(response.data);
  }

  @override
  Future<AiConversationModel> getConversationDetail(String id) async {
    final slug = await _getTenantSlug();
    final url = ApiConstants.iaConversacion(slug, id);
    final response = await apiClient.get(url);
    return AiConversationModel.fromJson(response.data);
  }

  @override
  Future<void> archiveConversation(String id) async {
    final slug = await _getTenantSlug();
    final url = ApiConstants.iaArchivar(slug, id);
    await apiClient.post(url, data: {});
  }

  @override
  Future<AiResponseModel> sendMessage(String id, String content) async {
    final slug = await _getTenantSlug();
    final url = ApiConstants.iaEnviarMensaje(slug, id);
    final response = await apiClient.post(url, data: {'contenido': content});
    return AiResponseModel.fromJson(response.data);
  }

  @override
  Future<AiActionModel> confirmAction(String id, String accionId) async {
    final slug = await _getTenantSlug();
    final url = ApiConstants.iaConfirmarAccion(slug, id);
    final response = await apiClient.post(url, data: {'accion_id': accionId});
    return AiActionModel.fromJson(response.data);
  }
}
