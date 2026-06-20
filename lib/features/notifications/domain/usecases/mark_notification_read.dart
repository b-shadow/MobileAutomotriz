import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/notifications/domain/entities/app_notification.dart';
import 'package:mobile1_app/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationReadParams {
  final String id;

  const MarkNotificationReadParams(this.id);
}

class MarkNotificationRead
    implements UseCase<AppNotification, MarkNotificationReadParams> {
  final NotificationsRepository repository;

  const MarkNotificationRead(this.repository);

  @override
  Future<Result<AppNotification>> call(MarkNotificationReadParams params) {
    return repository.markAsRead(params.id);
  }
}
