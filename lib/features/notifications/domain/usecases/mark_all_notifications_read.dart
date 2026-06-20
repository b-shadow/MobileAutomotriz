import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/notifications/domain/repositories/notifications_repository.dart';

class MarkAllNotificationsRead implements UseCase<int, NoParams> {
  final NotificationsRepository repository;

  const MarkAllNotificationsRead(this.repository);

  @override
  Future<Result<int>> call(NoParams params) {
    return repository.markAllAsRead();
  }
}
