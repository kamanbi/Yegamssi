extension DateTimeExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  String get yyyyMMdd {
    return '$year${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';
  }

  String get hhmm {
    return '${hour.toString().padLeft(2, '0')}${minute.toString().padLeft(2, '0')}';
  }

  String get kmaDate => yyyyMMdd;
  String get kmaTime => hhmm;
}
