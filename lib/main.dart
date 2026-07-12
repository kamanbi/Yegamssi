import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'core/background/background_refresh_scheduler.dart';
import 'core/config/supabase_config.dart';
import 'core/purchase/purchase_config.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/weather_cache_migration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await SupabaseConfig.initialize();
  await WeatherCacheMigration.migrateLegacyForecastCache();
  await BackgroundRefreshScheduler.initialize();

  final isPremium =
      await LocalStorage.getBool(PurchaseConfig.premiumStorageKey) ?? false;
  if (!isPremium) {
    MobileAds.instance.initialize();
  }

  runApp(const ProviderScope(child: YegamssiApp()));
}
