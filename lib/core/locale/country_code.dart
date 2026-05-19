/// 앱이 지원하는 국가 코드 — 전체 아키텍처의 디스패치 기준
enum CountryCode {
  kr, // 한국 (Phase 1)
  us, // 미국 (Phase 2)
  jp, // 일본 (Phase 3)
  cn, // 중국 (Phase 3)
  global, // 그 외 글로벌
}

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
      CountryCode.cn => 'zh',
      CountryCode.global => 'en',
    };
  }
}

/// 운세 언어팩 설정
enum AppLanguage { ko, en, ja, zh }

extension AppLanguageExtension on AppLanguage {
  /// 설정 화면 표기 (자국어)
  String get displayName => switch (this) {
        AppLanguage.ko => '한국어',
        AppLanguage.en => 'English',
        AppLanguage.ja => '日本語',
        AppLanguage.zh => '中文',
      };

  /// Supabase 테이블 접미사 — fortune_ko / fortune_en 등
  String get tableKey => name;

  /// 언어팩 활성 여부 (미출시 언어 비활성)
  bool get isAvailable => this == AppLanguage.ko || this == AppLanguage.en;
}
