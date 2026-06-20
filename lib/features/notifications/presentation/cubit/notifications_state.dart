import 'package:mobile1_app/features/notifications/domain/entities/app_notification.dart';
import 'package:mobile1_app/features/notifications/domain/entities/notification_summary.dart';

abstract class NotificationsState {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  final NotificationSummary summary;
  final bool soloNoLeidas;

  const NotificationsLoaded({
    required this.notifications,
    required this.summary,
    required this.soloNoLeidas,
  });
}

class NotificationsError extends NotificationsState {
  final String message;
  final List<AppNotification> notifications;
  final NotificationSummary? summary;
  final bool soloNoLeidas;

  const NotificationsError({
    required this.message,
    this.notifications = const [],
    this.summary,
    this.soloNoLeidas = false,
  });
}
