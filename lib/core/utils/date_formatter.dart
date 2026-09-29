/// Date & relative time formatting utility for PackSense analysis history.
class DateFormatter {
  DateFormatter._();

  /// Converts a [DateTime] into human-readable relative time string.
  ///
  /// Examples:
  /// - Just now
  /// - 15 minutes ago
  /// - 2 hours ago
  /// - Yesterday
  /// - 3 days ago
  /// - 12 days ago
  static String formatRelativeTime(DateTime dateTime, {DateTime? clock}) {
    final now = clock ?? DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative || difference.inSeconds < 60) {
      return 'Just now';
    }

    final minutes = difference.inMinutes;
    if (minutes < 60) {
      return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
    }

    final hours = difference.inHours;
    if (hours < 24) {
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    }

    final days = difference.inDays;
    if (days == 1) {
      return 'Yesterday';
    }
    if (days < 30) {
      return '$days days ago';
    }

    final months = (days / 30).floor();
    if (months < 12) {
      return months == 1 ? '1 month ago' : '$months months ago';
    }

    final years = (days / 365).floor();
    return years == 1 ? '1 year ago' : '$years years ago';
  }

  /// Formats date to user-friendly absolute timestamp for detailed screen.
  /// E.g. "Sep 29, 2026 • 2:45 PM"
  static String formatDetailedDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[local.month - 1];
    final day = local.day;
    final year = local.year;

    final hour24 = local.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');

    return '$month $day, $year • $hour12:$minute $period';
  }
}
