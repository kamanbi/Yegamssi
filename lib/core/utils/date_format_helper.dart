class AppDateFormat {
  AppDateFormat._();

  // Dart DateTime.weekday: 1=월(Monday) ~ 7=일(Sunday) — ISO 8601 기준
  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  static String format(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}년 $month월 $day일 (${weekdayLabel(dateTime)})';
  }

  static String compact(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}.$month.$day';
  }

  /// 위젯 날짜 (상단): 2026.04.18
  static String widgetDate(DateTime dateTime) => compact(dateTime);

  /// 위젯 시간·요일 (하단): 금요일 · 10:53
  static String widgetTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${weekdayFullLabel(dateTime)} · $hour:$minute';
  }

  static String weekdayLabel(DateTime dateTime) {
    return _weekdays[dateTime.weekday - 1];
  }

  static String weekdayFullLabel(DateTime dateTime) {
    return '${weekdayLabel(dateTime)}요일';
  }
}
