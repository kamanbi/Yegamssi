import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';
import 'features/widget_bridge/background_weather_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await SupabaseConfig.initialize();
  MobileAds.instance.initialize();

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerOneOffTask(
    '${kBackgroundWeatherSyncTask}_startup',
    kBackgroundWeatherSyncTask,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    initialDelay: const Duration(seconds: 10),
  );
  await Workmanager().registerPeriodicTask(
    kBackgroundWeatherSyncTask,
    kBackgroundWeatherSyncTask,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    initialDelay: const Duration(minutes: 1),
  );

  runApp(const ProviderScope(child: YegamssiApp()));
}
