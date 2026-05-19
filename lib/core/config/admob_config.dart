import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdMobConfig {
  AdMobConfig._();

  static const String _defaultBannerAdUnitId =
      'ca-app-pub-4821917176258982/1094010880';
  static const String _defaultInterstitialAdUnitId =
      'ca-app-pub-4821917176258982/6485938362';

  static String get bannerAdUnitId =>
      _envValue('ADMOB_BANNER_AD_UNIT_ID') ??
      _envValue('baner ad ID') ??
      _defaultBannerAdUnitId;

  static String get interstitialAdUnitId =>
      _envValue('ADMOB_INTERSTITIAL_AD_UNIT_ID') ??
      _envValue('Full ad ID') ??
      _defaultInterstitialAdUnitId;

  static String? _envValue(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
