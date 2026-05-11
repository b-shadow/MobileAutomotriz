import '../../../../core/network/api_client.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/report_models.dart';

abstract class ReportsRemoteDataSource {
  Future<List<TopVehicleModel>> getTopVehicles();
  Future<VehicleReportDetailModel> getVehicleReport(String placa);
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
  Future<List<TopVehicleModel>> getTopVehicles() async {
    final slug = await _getTenantSlug();
    final url = ApiConstants.reportesVehiculo(slug);
    final response = await apiClient.get(url);
    final data = response.data['top_vehiculos'] as List<dynamic>? ?? [];
    return data.map((e) => TopVehicleModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<VehicleReportDetailModel> getVehicleReport(String placa) async {
    final slug = await _getTenantSlug();
    final url = '${ApiConstants.reportesVehiculo(slug)}?placa=$placa';
    final response = await apiClient.get(url);
    return VehicleReportDetailModel.fromJson(response.data as Map<String, dynamic>);
  }
}
