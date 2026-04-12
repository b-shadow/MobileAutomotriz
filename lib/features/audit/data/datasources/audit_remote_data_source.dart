import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/audit/data/models/audit_event_model.dart';
import 'package:mobile1_app/features/audit/data/models/audit_summary_model.dart';
import 'package:mobile1_app/features/audit/domain/entities/audit_filters.dart';

abstract class AuditRemoteDataSource {
  Future<List<AuditEventModel>> getAuditLogs(AuditFilters filters);
  Future<AuditEventModel> getAuditDetail(String id);
  Future<AuditSummaryModel> getAuditSummary();
}

class AuditRemoteDataSourceImpl implements AuditRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const AuditRemoteDataSourceImpl({
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
  Future<List<AuditEventModel>> getAuditLogs(AuditFilters filters) async {
    try {
      final response = await apiClient.get(
        ApiConstants.auditoria(_slug),
        queryParameters: filters.toQueryParams(),
      );
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
          .map(AuditEventModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AuditEventModel> getAuditDetail(String id) async {
    try {
      final response = await apiClient.get(ApiConstants.auditoriaDetalle(_slug, id));
      return AuditEventModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AuditSummaryModel> getAuditSummary() async {
    try {
      final response = await apiClient.get(ApiConstants.auditoriaResumen(_slug));
      return AuditSummaryModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}

