import 'package:mobile1_app/core/error/exceptions.dart';
import 'package:mobile1_app/core/error/failures.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/network/network_info.dart';
import 'package:mobile1_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:mobile1_app/features/notifications/domain/entities/app_notification.dart';
import 'package:mobile1_app/features/notifications/domain/entities/notification_summary.dart';
import 'package:mobile1_app/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const NotificationsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Result<List<AppNotification>>> getNotifications({
    bool soloNoLeidas = false,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final notifications =
          await remoteDataSource.getNotifications(soloNoLeidas: soloNoLeidas);
      return Success(notifications);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<NotificationSummary>> getSummary() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final summary = await remoteDataSource.getSummary();
      return Success(summary);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<AppNotification>> markAsRead(String id) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final notification = await remoteDataSource.markAsRead(id);
      return Success(notification);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Result<int>> markAllAsRead() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }

    try {
      final updated = await remoteDataSource.markAllAsRead();
      return Success(updated);
    } on ServerException catch (e) {
      return Err(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
