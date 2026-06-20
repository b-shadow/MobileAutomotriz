import 'package:mobile1_app/features/notifications/domain/entities/notification_summary.dart';

class NotificationSummaryModel extends NotificationSummary {
  const NotificationSummaryModel({
    required super.total,
    required super.noLeidas,
  });

  factory NotificationSummaryModel.fromJson(Map<String, dynamic> json) {
    return NotificationSummaryModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      noLeidas: (json['no_leidas'] as num?)?.toInt() ?? 0,
    );
  }
}
