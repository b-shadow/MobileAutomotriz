import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/appointment/data/models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> getAppointmentDetail(String id);
  Future<AppointmentModel> createAppointment(Map<String, dynamic> data);
  Future<Map<String, dynamic>> cancelAppointment({
    required String id,
    required String motivo,
  });
  Future<AppointmentModel> rescheduleAppointment({
    required String id,
    required Map<String, dynamic> data,
  });
  Future<Map<String, dynamic>> markNoShow({
    required String id,
    String? observacion,
  });
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const AppointmentRemoteDataSourceImpl({
    required this.apiClient,
    required this.sessionStorage,
  });

  String get _slug {
    final userData = sessionStorage.userData;
    if (userData != null && userData['tenant'] is Map<String, dynamic>) {
      final tenant = userData['tenant'] as Map<String, dynamic>;
      final slug = tenant['slug'] as String?;
      if (slug != null && slug.isNotEmpty) return slug;
    }
    return EnvConfig.tenantSlug;
  }

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final response = await apiClient.get(ApiConstants.citas(_slug));
      final data = response.data;

      final List<dynamic> rows;
      if (data is Map<String, dynamic> && data['results'] is List) {
        rows = data['results'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        rows = data;
      } else {
        rows = const [];
      }

      return rows
          .whereType<Map<String, dynamic>>()
          .map(AppointmentModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AppointmentModel> getAppointmentDetail(String id) async {
    try {
      final response = await apiClient.get(ApiConstants.cita(_slug, id));
      return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AppointmentModel> createAppointment(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiConstants.citas(_slug),
        data: data,
      );
      return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> cancelAppointment({
    required String id,
    required String motivo,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.cancelarCita(_slug, id),
        data: {'motivo_cancelacion': motivo},
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AppointmentModel> rescheduleAppointment({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.reprogramarCita(_slug, id),
        data: data,
      );
      return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> markNoShow({
    required String id,
    String? observacion,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (observacion != null && observacion.isNotEmpty) {
        body['observacion'] = observacion;
      }
      final response = await apiClient.post(
        ApiConstants.marcarNoShowCita(_slug, id),
        data: body,
      );
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
