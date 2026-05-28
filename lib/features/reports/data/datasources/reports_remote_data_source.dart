import '../../../../core/network/api_client.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/report_data.dart';

abstract class ReportsRemoteDataSource {
  Future<ReportData> getReportData(String endpoint, Map<String, dynamic> queryParams);
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  ReportsRemoteDataSourceImpl({
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
  Future<ReportData> getReportData(String endpoint, Map<String, dynamic> queryParams) async {
    final slug = await _getTenantSlug();
    
    // Generar string de parametros
    String queryString = '';
    if (queryParams.isNotEmpty) {
      final List<String> paramsList = [];
      queryParams.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          paramsList.add('$key=${Uri.encodeComponent(value.toString())}');
        }
      });
      if (paramsList.isNotEmpty) {
        queryString = '?${paramsList.join('&')}';
      }
    }
    
    // endpoint deberia ser por ejemplo 'global_stats', 'vehiculo', etc.
    final url = '/api/$slug/comunicacion-control/reportes/$endpoint/$queryString';
    final response = await apiClient.get(url);
    
    return ReportData(response.data as Map<String, dynamic>);
  }
}
