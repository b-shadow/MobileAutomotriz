import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/notifications/domain/entities/app_notification.dart';
import 'package:mobile1_app/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsParams {
  final bool soloNoLeidas;

  const GetNotificationsParams({
    this.soloNoLeidas = false,
  });
}

class GetNotifications
    implements UseCase<List<AppNotification>, GetNotificationsParams> {
  final NotificationsRepository repository;

  const GetNotifications(this.repository);

  @override
  Future<Result<List<AppNotification>>> call(GetNotificationsParams params) {
    return repository.getNotifications(soloNoLeidas: params.soloNoLeidas);
  }
}
