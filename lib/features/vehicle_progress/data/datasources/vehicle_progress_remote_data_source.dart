import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/session_storage.dart';
import '../../../workshop_progress/data/models/progress_log_model.dart';
import '../models/vehicle_progress_model.dart';
import '../models/vehicle_progress_detail_model.dart';

abstract class VehicleProgressRemoteDataSource {
  Future<List<VehicleProgressModel>> getOperativeAppointments();
  Future<VehicleProgressDetailModel> getVehicleProgressDetail(String citaId);
  Future<VehicleProgressDetailModel> registerArrival(String citaId);
  Future<VehicleProgressDetailModel> markInProcess(String citaId);
  Future<VehicleProgressDetailModel> markReturned(String citaId);
  Future<List<ProgressLogModel>> getProgressHistory(String citaId);
  Future<void> addManualProgress({
    required String citaId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  });
}

class VehicleProgressRemoteDataSourceImpl implements VehicleProgressRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  VehicleProgressRemoteDataSourceImpl({required this.apiClient, required this.sessionStorage});

  Future<String> _getTenantSlug() async {
    final userData = sessionStorage.userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      return tenant['slug'] as String? ?? '';
    }
    throw Exception('No tenant found in session');
  }

  @override
  Future<List<VehicleProgressModel>> getOperativeAppointments() async {
    final slug = await _getTenantSlug();
    final response = await apiClient.get(ApiConstants.citasRecepcionOperativa(slug));
    final results = response.data['results'] as List;
    return results.map((e) => VehicleProgressModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<VehicleProgressDetailModel> getVehicleProgressDetail(String citaId) async {
    final slug = await _getTenantSlug();
    final response = await apiClient.get('${ApiConstants.citas(slug)}$citaId/recepcion/');
    return VehicleProgressDetailModel.fromJson(response.data);
  }

  @override
  Future<VehicleProgressDetailModel> registerArrival(String citaId) async {
    final slug = await _getTenantSlug();
    final response = await apiClient.post(ApiConstants.citaRegistrarLlegada(slug, citaId));
    return VehicleProgressDetailModel.fromJson(response.data);
  }

  @override
  Future<VehicleProgressDetailModel> markInProcess(String citaId) async {
    final slug = await _getTenantSlug();
    final response = await apiClient.post(ApiConstants.citaMarcarEnProceso(slug, citaId));
    return VehicleProgressDetailModel.fromJson(response.data);
  }

  @override
  Future<VehicleProgressDetailModel> markReturned(String citaId) async {
    final slug = await _getTenantSlug();
    final response = await apiClient.post(ApiConstants.citaMarcarVehiculoDevuelto(slug, citaId));
    return VehicleProgressDetailModel.fromJson(response.data);
  }

  @override
  Future<List<ProgressLogModel>> getProgressHistory(String citaId) async {
    final slug = await _getTenantSlug();
    final response = await apiClient.get(ApiConstants.avancesVehiculoList(slug));
    final data = response.data as List;
    
    // Filter history for this specific appointment
    final filtered = data.where((item) => item['cita'] == citaId).toList();
    return filtered.map((e) => ProgressLogModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addManualProgress({
    required String citaId,
    required String type,
    required String status,
    required String message,
    int? percentage,
  }) async {
    final slug = await _getTenantSlug();
    await apiClient.post(
      ApiConstants.avancesVehiculoList(slug),
      data: {
        'cita': citaId,
        'tipo': type,
        'estado_nuevo': status,
        'mensaje': message,
        if (percentage != null) 'porcentaje_avance': percentage,
      },
    );
  }
}
