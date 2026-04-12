import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/workspace/data/models/workspace_schedule_model.dart';
import 'package:mobile1_app/features/workspace/data/models/workspace_space_model.dart';

abstract class WorkspaceRemoteDataSource {
  Future<List<WorkspaceSpaceModel>> getSpaces();
  Future<WorkspaceSpaceModel> createSpace(Map<String, dynamic> data);
  Future<WorkspaceSpaceModel> updateSpaceActive({
    required String spaceId,
    required bool activo,
    String? motivo,
  });

  Future<List<WorkspaceScheduleModel>> getSpaceSchedules(String spaceId);
  Future<WorkspaceScheduleModel> createSpaceSchedule({
    required String spaceId,
    required Map<String, dynamic> data,
  });
  Future<WorkspaceScheduleModel> updateSpaceSchedule({
    required String spaceId,
    required String scheduleId,
    required Map<String, dynamic> data,
  });
}

class WorkspaceRemoteDataSourceImpl implements WorkspaceRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const WorkspaceRemoteDataSourceImpl({
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
  Future<List<WorkspaceSpaceModel>> getSpaces() async {
    try {
      final response = await apiClient.get(ApiConstants.espacios(_slug));
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
          .map(WorkspaceSpaceModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkspaceSpaceModel> createSpace(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(ApiConstants.espacios(_slug), data: data);
      return WorkspaceSpaceModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkspaceSpaceModel> updateSpaceActive({
    required String spaceId,
    required bool activo,
    String? motivo,
  }) async {
    try {
      final payload = <String, dynamic>{'activo': activo};
      if (motivo != null && motivo.trim().isNotEmpty) {
        payload['motivo'] = motivo.trim();
      }

      final response = await apiClient.patch(
        ApiConstants.espacioActivo(_slug, spaceId),
        data: payload,
      );
      return WorkspaceSpaceModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<WorkspaceScheduleModel>> getSpaceSchedules(String spaceId) async {
    try {
      final response = await apiClient.get(ApiConstants.espacioHorarios(_slug, spaceId));
      final data = response.data;

      final List<dynamic> rows;
      if (data is Map<String, dynamic> && data['results'] is List) {
        rows = data['results'] as List<dynamic>;
      } else if (data is Map<String, dynamic> && data['horarios'] is List) {
        rows = data['horarios'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        rows = data;
      } else {
        rows = const [];
      }

      return rows
          .whereType<Map<String, dynamic>>()
          .map(WorkspaceScheduleModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkspaceScheduleModel> createSpaceSchedule({
    required String spaceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.espacioHorarios(_slug, spaceId),
        data: data,
      );
      return WorkspaceScheduleModel.fromJson(_extractScheduleJson(response.data));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<WorkspaceScheduleModel> updateSpaceSchedule({
    required String spaceId,
    required String scheduleId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiClient.patch(
        ApiConstants.editarHorarioEspacio(_slug, spaceId, scheduleId),
        data: data,
      );
      return WorkspaceScheduleModel.fromJson(_extractScheduleJson(response.data));
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Map<String, dynamic> _extractScheduleJson(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['horario'] ?? data['schedule'] ?? data['data'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return data;
    }
    return <String, dynamic>{};
  }
}

