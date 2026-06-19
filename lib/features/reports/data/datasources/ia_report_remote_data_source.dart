import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/ia_report_result.dart';

abstract class IaReportRemoteDataSource {
  /// Sends a natural-language prompt to the AI reports endpoint
  /// and returns the structured result.
  Future<IaReportResult> askIaReport(String prompt);

  /// Transcribes an audio file using the existing IA transcription endpoint.
  Future<String> transcribeAudio(String filePath);
}

class IaReportRemoteDataSourceImpl implements IaReportRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  IaReportRemoteDataSourceImpl({
    required this.apiClient,
    required this.sessionStorage,
  });

  Future<String> _getTenantSlug() async {
    final userData = sessionStorage.userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      return tenant['slug'] as String? ?? '';
    }
    throw Exception('No tenant found in session');
  }

  @override
  Future<IaReportResult> askIaReport(String prompt) async {
    final slug = await _getTenantSlug();
    final url = ApiConstants.reportesIaAsk(slug);
    final response = await apiClient.post(url, data: {'prompt': prompt});
    return IaReportResult.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<String> transcribeAudio(String filePath) async {
    final slug = await _getTenantSlug();
    final url = ApiConstants.iaTranscribir(slug);

    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(filePath, filename: 'voice_input.wav'),
    });

    final response = await apiClient.post(url, data: formData);
    return response.data['texto'] as String? ?? '';
  }
}
