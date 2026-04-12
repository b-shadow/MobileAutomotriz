import 'package:intl/intl.dart';

/// Utility for formatting dates throughout the app.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullDate = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd/MM/yy');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, HH:mm');

  /// e.g., "10 Abr 2026"
  static String fullDate(DateTime date) => _fullDate.format(date);

  /// e.g., "10/04/26"
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// e.g., "21:37"
  static String time(DateTime date) => _time.format(date);

  /// e.g., "10 Abr 2026, 21:37"
  static String dateTime(DateTime date) => _dateTime.format(date);

  /// Shows relative time like "Hace 5 min", "Hace 2 h", "Ayer", etc.
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return fullDate(date);
  }
}
