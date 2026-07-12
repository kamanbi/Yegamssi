import 'dart:ui';

import '../../l10n/app_localizations.dart';

enum CountryCode { kr, us, jp, cn, global }

extension CountryCodeExtension on CountryCode {
  String localizedName(AppLocalizations l10n) {
    return switch (this) {
      CountryCode.kr => l10n.countryKorea,
      CountryCode.us => l10n.countryUnitedStates,
      CountryCode.jp => l10n.countryJapan,
      CountryCode.cn => l10n.countryChina,
      CountryCode.global => l10n.countryGlobal,
    };
  }

  String get displayName {
    return switch (this) {
      CountryCode.kr => 'Korea',
      CountryCode.us => 'United States',
      CountryCode.jp => 'Japan',
      CountryCode.cn => 'China',
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

enum AppLanguage { ko, ja, en, ro, hi, zh, es, pt, de, fr, vi }

extension AppLanguageExtension on AppLanguage {
  String get displayName => switch (this) {
    AppLanguage.ko => '\uD55C\uAD6D\uC5B4',
    AppLanguage.ja => '\u65E5\u672C\u8A9E',
    AppLanguage.en => 'English',
    AppLanguage.ro => 'Rom\u00E2n\u0103',
    AppLanguage.hi => '\u0939\u093F\u0928\u094D\u0926\u0940',
    AppLanguage.zh => '\u4E2D\u6587(\u7B80\u4F53)',
    AppLanguage.es => 'Espa\u00F1ol',
    AppLanguage.pt => 'Portugu\u00EAs',
    AppLanguage.de => 'Deutsch',
    AppLanguage.fr => 'Fran\u00E7ais',
    AppLanguage.vi => 'Ti\u1EBFng Vi\u1EC7t',
  };

  String get shortLabel => switch (this) {
    AppLanguage.ko => 'KO',
    AppLanguage.ja => 'JA',
    AppLanguage.en => 'EN',
    AppLanguage.ro => 'RO',
    AppLanguage.hi => 'HI',
    AppLanguage.zh => 'ZH',
    AppLanguage.es => 'ES',
    AppLanguage.pt => 'PT',
    AppLanguage.de => 'DE',
    AppLanguage.fr => 'FR',
    AppLanguage.vi => 'VI',
  };

  Locale get locale => Locale(name);

  String get tableKey => name;

  bool get isAvailable => true;
}
