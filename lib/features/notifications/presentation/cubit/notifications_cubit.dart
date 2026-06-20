import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile1_app/core/error/result.dart';
import 'package:mobile1_app/core/usecases/usecase.dart';
import 'package:mobile1_app/features/notifications/domain/entities/app_notification.dart';
import 'package:mobile1_app/features/notifications/domain/entities/notification_summary.dart';
import 'package:mobile1_app/features/notifications/domain/usecases/get_notification_summary.dart';
import 'package:mobile1_app/features/notifications/domain/usecases/get_notifications.dart';
import 'package:mobile1_app/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:mobile1_app/features/notifications/domain/usecases/mark_notification_read.dart';

import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotifications _getNotifications;
  final GetNotificationSummary _getNotificationSummary;
  final MarkNotificationRead _markNotificationRead;
  final MarkAllNotificationsRead _markAllNotificationsRead;

  List<AppNotification> _notifications = const [];
  NotificationSummary _summary = const NotificationSummary(total: 0, noLeidas: 0);
  bool _soloNoLeidas = false;

  NotificationsCubit({
    required GetNotifications getNotifications,
    required GetNotificationSummary getNotificationSummary,
    required MarkNotificationRead markNotificationRead,
    required MarkAllNotificationsRead markAllNotificationsRead,
  })  : _getNotifications = getNotifications,
        _getNotificationSummary = getNotificationSummary,
        _markNotificationRead = markNotificationRead,
        _markAllNotificationsRead = markAllNotificationsRead,
        super(const NotificationsInitial());

  Future<void> fetchInitial() async {
    emit(const NotificationsLoading());
    await _refreshData();
  }

  Future<void> refresh() async {
    await _refreshData();
  }

  Future<void> toggleSoloNoLeidas(bool value) async {
    _soloNoLeidas = value;
    emit(const NotificationsLoading());
    await _refreshData();
  }

  Future<void> marcarLeida(String id) async {
    final result = await _markNotificationRead(MarkNotificationReadParams(id));
    switch (result) {
      case Success(:final data):
        _notifications = _notifications
            .map((notification) => notification.id == id ? data : notification)
            .toList();
        _summary = NotificationSummary(
          total: _summary.total,
          noLeidas: _summary.noLeidas > 0 ? _summary.noLeidas - 1 : 0,
        );
        if (_soloNoLeidas) {
          _notifications =
              _notifications.where((notification) => !notification.leida).toList();
        }
        emit(
          NotificationsLoaded(
            notifications: _notifications,
            summary: _summary,
            soloNoLeidas: _soloNoLeidas,
          ),
        );
      case Err(:final failure):
        emit(
          NotificationsError(
            message: failure.message,
            notifications: _notifications,
            summary: _summary,
            soloNoLeidas: _soloNoLeidas,
          ),
        );
    }
  }

  Future<void> marcarTodasLeidas() async {
    final result = await _markAllNotificationsRead(const NoParams());
    switch (result) {
      case Success():
        _notifications = _notifications
            .map(
              (notification) => notification.copyWith(
                leida: true,
                leidaAt: DateTime.now(),
              ),
            )
            .toList();
        _summary = NotificationSummary(total: _summary.total, noLeidas: 0);
        if (_soloNoLeidas) {
          _notifications = const [];
        }
        emit(
          NotificationsLoaded(
            notifications: _notifications,
            summary: _summary,
            soloNoLeidas: _soloNoLeidas,
          ),
        );
      case Err(:final failure):
        emit(
          NotificationsError(
            message: failure.message,
            notifications: _notifications,
            summary: _summary,
            soloNoLeidas: _soloNoLeidas,
          ),
        );
    }
  }

  Future<void> _refreshData() async {
    final summaryResult = await _getNotificationSummary(const NoParams());
    if (summaryResult is Success<NotificationSummary>) {
      _summary = summaryResult.data;
    }

    final notificationsResult = await _getNotifications(
      GetNotificationsParams(soloNoLeidas: _soloNoLeidas),
    );

    switch (notificationsResult) {
      case Success(:final data):
        _notifications = data;
        emit(
          NotificationsLoaded(
            notifications: _notifications,
            summary: _summary,
            soloNoLeidas: _soloNoLeidas,
          ),
        );
      case Err(:final failure):
        emit(
          NotificationsError(
            message: failure.message,
            notifications: _notifications,
            summary: _summary,
            soloNoLeidas: _soloNoLeidas,
          ),
        );
    }
  }
}
