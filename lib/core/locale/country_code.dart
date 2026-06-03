import 'dart:ui';

enum CountryCode { kr, us, jp, cn, global }

extension CountryCodeExtension on CountryCode {
  String get displayName {
    return switch (this) {
      CountryCode.kr => '한국',
      CountryCode.us => 'United States',
      CountryCode.jp => '日本',
      CountryCode.cn => '中国',
      CountryCode.global => 'Global',
    };
  }

  String get isoCode {
    return switch (this) {
      CountryCode.kr => 'KR',
      CountryCode.us => 'US',
      CountryCode.jp => 'JP',
      CountryCode.cn => 'CN',
      CountryCode.global => 'GLOBAL',
    };
  }

  String get defaultLocale {
    return switch (this) {
      CountryCode.kr => 'ko',
      CountryCode.us => 'en',
      CountryCode.jp => 'ja',
      CountryCode.cn => 'en',
      CountryCode.global => 'en',
    };
  }
}

enum AppLanguage { ko, ja, en }

extension AppLanguageExtension on AppLanguage {
  String get displayName => switch (this) {
    AppLanguage.ko => '한국어',
    AppLanguage.ja => '日本語',
    AppLanguage.en => 'English',
  };

  String get shortLabel => switch (this) {
    AppLanguage.ko => 'KO',
    AppLanguage.ja => 'JA',
    AppLanguage.en => 'EN',
  };

  Locale get locale => Locale(name);

  String get tableKey => name;

  bool get isAvailable => true;
}
