import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/notifications/domain/entities/notification_summary.dart';
import 'package:mobile1_app/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationSummary
    implements UseCase<NotificationSummary, NoParams> {
  final NotificationsRepository repository;

  const GetNotificationSummary(this.repository);

  @override
  Future<Result<NotificationSummary>> call(NoParams params) {
    return repository.getSummary();
  }
}
