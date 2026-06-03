class AppDateFormat {
  AppDateFormat._();

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static String format(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}.$month.$day (${weekdayLabel(dateTime)})';
  }

  static String compact(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}.$month.$day';
  }

  static String widgetDate(DateTime dateTime) => compact(dateTime);

  static String widgetTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${weekdayFullLabel(dateTime)} · $hour:$minute';
  }

  static String weekdayLabel(DateTime dateTime) {
    return _weekdays[dateTime.weekday - 1];
  }

  static String weekdayFullLabel(DateTime dateTime) {
    return weekdayLabel(dateTime);
  }
}
