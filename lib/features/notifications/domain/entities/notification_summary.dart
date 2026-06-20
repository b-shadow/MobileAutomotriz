import 'package:equatable/equatable.dart';

class NotificationSummary extends Equatable {
  final int total;
  final int noLeidas;

  const NotificationSummary({
    required this.total,
    required this.noLeidas,
  });

  @override
  List<Object?> get props => [total, noLeidas];
}
