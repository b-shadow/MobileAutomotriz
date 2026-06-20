import 'package:mobile1_app/core/error/result.dart';

import '../entities/app_notification.dart';
import '../entities/notification_summary.dart';

abstract class NotificationsRepository {
  Future<Result<List<AppNotification>>> getNotifications({
    bool soloNoLeidas = false,
  });

  Future<Result<NotificationSummary>> getSummary();

  Future<Result<AppNotification>> markAsRead(String id);

  Future<Result<int>> markAllAsRead();
}
