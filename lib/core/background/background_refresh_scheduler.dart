import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../config/supabase_config.dart';
import '../refresh/app_refresh_controller.dart';
import '../refresh/refresh_policy.dart';
import '../storage/weather_cache_migration.dart';

const _backgroundRefreshUniqueName = 'yegamssi_background_signal_refresh';
const _backgroundRefreshTaskName = 'yegamssi.refresh.signals';

class BackgroundRefreshScheduler {
  const BackgroundRefreshScheduler._();

  static Future<void> initialize() async {
    await Workmanager().initialize(backgroundRefreshDispatcher);
    await Workmanager().registerPeriodicTask(
      _backgroundRefreshUniqueName,
      _backgroundRefreshTaskName,
      frequency: RefreshPolicy.weatherRefreshInterval,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 10),
      tag: _backgroundRefreshUniqueName,
    );
  }
}

@pragma('vm:entry-point')
void backgroundRefreshDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != _backgroundRefreshTaskName) {
      return true;
    }

    try {
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();
      await SupabaseConfig.initialize();
      await WeatherCacheMigration.migrateLegacyForecastCache();

      final container = ProviderContainer();
      try {
        await container.read(appRefreshControllerProvider).refreshSignals();
      } finally {
        container.dispose();
      }
      return true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[BackgroundRefresh] failed: $error\n$stackTrace');
      }
      return false;
    }
  });
}
