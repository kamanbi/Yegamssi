import '../locale/country_code.dart';

class AppDateFormat {
  AppDateFormat._();

  static const Map<AppLanguage, List<String>> _weekdays = {
    AppLanguage.ko: [
      '\uC6D4',
      '\uD654',
      '\uC218',
      '\uBAA9',
      '\uAE08',
      '\uD1A0',
      '\uC77C',
    ],
    AppLanguage.ja: [
      '\u6708',
      '\u706B',
      '\u6C34',
      '\u6728',
      '\u91D1',
      '\u571F',
      '\u65E5',
    ],
    AppLanguage.en: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    AppLanguage.ro: ['Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'S\u00E2m', 'Dum'],
    AppLanguage.hi: [
      '\u0938\u094B\u092E',
      '\u092E\u0902\u0917\u0932',
      '\u092C\u0941\u0927',
      '\u0917\u0941\u0930\u0941',
      '\u0936\u0941\u0915\u094D\u0930',
      '\u0936\u0928\u093F',
      '\u0930\u0935\u093F',
    ],
    AppLanguage.zh: [
      '\u5468\u4E00',
      '\u5468\u4E8C',
      '\u5468\u4E09',
      '\u5468\u56DB',
      '\u5468\u4E94',
      '\u5468\u516D',
      '\u5468\u65E5',
    ],
    AppLanguage.es: ['Lun', 'Mar', 'Mi\u00E9', 'Jue', 'Vie', 'S\u00E1b', 'Dom'],
    AppLanguage.pt: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'S\u00E1b', 'Dom'],
    AppLanguage.de: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
    AppLanguage.fr: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
    AppLanguage.vi: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
  };

  static String format(DateTime dateTime, {required AppLanguage language}) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final weekday = weekdayLabel(dateTime, language: language);
    return switch (language) {
      AppLanguage.ko =>
        '${dateTime.year}\uB144 $month\uC6D4 $day\uC77C ($weekday)',
      AppLanguage.ja =>
        '${dateTime.year}\u5E74$month\u6708$day\u65E5 ($weekday)',
      AppLanguage.en => '$month/$day/${dateTime.year} ($weekday)',
      AppLanguage.ro => '$day.$month.${dateTime.year} ($weekday)',
      AppLanguage.hi => '$day/$month/${dateTime.year} ($weekday)',
      AppLanguage.zh => '${dateTime.year}年$month月$day日 ($weekday)',
      AppLanguage.es => '$day/$month/${dateTime.year} ($weekday)',
      AppLanguage.pt => '$day/$month/${dateTime.year} ($weekday)',
      AppLanguage.de => '$day.$month.${dateTime.year} ($weekday)',
      AppLanguage.fr => '$day/$month/${dateTime.year} ($weekday)',
      AppLanguage.vi => '$day/$month/${dateTime.year} ($weekday)',
    };
  }

  static String compact(DateTime dateTime, {required AppLanguage language}) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return switch (language) {
      AppLanguage.ko => '${dateTime.year}.$month.$day',
      AppLanguage.ja => '${dateTime.year}/$month/$day',
      AppLanguage.en => '$month/$day/${dateTime.year}',
      AppLanguage.ro => '$day.$month.${dateTime.year}',
      AppLanguage.hi => '$day/$month/${dateTime.year}',
      AppLanguage.zh => '${dateTime.year}.$month.$day',
      AppLanguage.es => '$day/$month/${dateTime.year}',
      AppLanguage.pt => '$day/$month/${dateTime.year}',
      AppLanguage.de => '$day.$month.${dateTime.year}',
      AppLanguage.fr => '$day/$month/${dateTime.year}',
      AppLanguage.vi => '$day/$month/${dateTime.year}',
    };
  }

  /// 날짜 + 요일 + 오전/오후 시간 (전 페이지 공통 헤더 서식)
  static String formatWithTime(
    DateTime dateTime, {
    required AppLanguage language,
  }) {
    return '${format(dateTime, language: language)} · ${amPmTime(dateTime, language: language)}';
  }

  /// 오전/오후 HH:mm 형식 (운세 슬롯 표시 등)
  static String amPmTime(DateTime dateTime, {required AppLanguage language}) {
    final isAm = dateTime.hour < 12;
    final h = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
        ? dateTime.hour - 12
        : dateTime.hour;
    final hh = h.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return switch (language) {
      AppLanguage.ko => '${isAm ? '오전' : '오후'} $hh:$mm',
      AppLanguage.ja => '${isAm ? '午前' : '午後'} $hh:$mm',
      AppLanguage.zh => '${isAm ? '上午' : '下午'} $hh:$mm',
      _ => '$hh:$mm ${isAm ? 'AM' : 'PM'}',
    };
  }

  static String widgetDate(DateTime dateTime, {required AppLanguage language}) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '${dateTime.year}/$month/$day';
  }

  static String widgetTime(DateTime dateTime, {required AppLanguage language}) {
    return '${weekdayFullLabel(dateTime, language: language)} \u00B7 '
        '${amPmTime(dateTime, language: language)}';
  }

  static String weekdayLabel(
    DateTime dateTime, {
    required AppLanguage language,
  }) {
    return _weekdays[language]![dateTime.weekday - 1];
  }

  static String weekdayFullLabel(
    DateTime dateTime, {
    required AppLanguage language,
  }) {
    final label = weekdayLabel(dateTime, language: language);
    return switch (language) {
      AppLanguage.ko => '$label\uC694\uC77C',
      AppLanguage.ja => '$label\u66DC\u65E5',
      AppLanguage.en => label,
      AppLanguage.ro => label,
      AppLanguage.hi => '$label\u0935\u093E\u0930',
      AppLanguage.zh => '$label\u66DC',
      AppLanguage.es => label,
      AppLanguage.pt => label,
      AppLanguage.de => label,
      AppLanguage.fr => label,
      AppLanguage.vi => label,
    };
  }
}
