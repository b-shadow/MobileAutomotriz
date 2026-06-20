import 'package:mobile1_app/config/env/env_config.dart';
import 'package:mobile1_app/core/constants/api_constants.dart';
import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/network/api_client.dart';
import 'package:mobile1_app/core/storage/session_storage.dart';
import 'package:mobile1_app/features/notifications/data/models/app_notification_model.dart';
import 'package:mobile1_app/features/notifications/data/models/notification_summary_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<AppNotificationModel>> getNotifications({bool soloNoLeidas = false});
  Future<NotificationSummaryModel> getSummary();
  Future<AppNotificationModel> markAsRead(String id);
  Future<int> markAllAsRead();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient apiClient;
  final SessionStorage sessionStorage;

  const NotificationsRemoteDataSourceImpl({
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
  Future<List<AppNotificationModel>> getNotifications({
    bool soloNoLeidas = false,
  }) async {
    try {
      final response = await apiClient.get(
        ApiConstants.notificaciones(_slug),
        queryParameters: soloNoLeidas ? {'solo_no_leidas': true} : null,
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
          .map(AppNotificationModel.fromJson)
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<NotificationSummaryModel> getSummary() async {
    try {
      final response = await apiClient.get(ApiConstants.notificacionesResumen(_slug));
      return NotificationSummaryModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AppNotificationModel> markAsRead(String id) async {
    try {
      final response = await apiClient.post(ApiConstants.marcarNotificacionLeida(_slug, id));
      return AppNotificationModel.fromJson(response.data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> markAllAsRead() async {
    try {
      final response = await apiClient.post(ApiConstants.marcarTodasNotificacionesLeidas(_slug));
      final data = response.data as Map<String, dynamic>;
      return (data['updated'] as num?)?.toInt() ?? 0;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
