class DateFormatter {
  /// Formats DateTime to -> "Mon, 23rd Mar '26"
  static String formatDate(DateTime? date) {
    if (date == null) return '';

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final dayName = days[date.weekday - 1];
    final day = date.day;
    final suffix = getDaySuffix(day);
    final month = months[date.month - 1];
    final year = date.year.toString().substring(2);

    return '$dayName, $day$suffix $month \'$year';
  }

  /// Formats DateTime to -> "Mon, 23rd Mar '26 - 2:30pm"
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';

    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'pm' : 'am';

    return '${formatDate(date)} - $hour:$minute$period';
  }

  /// Returns ordinal suffix for a day number
  static String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
