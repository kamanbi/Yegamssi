import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../config/supabase_config.dart';
import '../error/failure.dart';
import '../refresh/app_refresh_controller.dart';
import '../refresh/refresh_policy.dart';
import '../storage/location_cache_store.dart';
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
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
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

    return runBackgroundRefreshTask(() async {
      WidgetsFlutterBinding.ensureInitialized();
      DartPluginRegistrant.ensureInitialized();
      await SupabaseConfig.initialize();
      await WeatherCacheMigration.migrateLegacyForecastCache();

      final container = ProviderContainer();
      try {
        await container
            .read(appRefreshControllerProvider)
            .refreshSignals(positionOverride: await LocationCacheStore.load());
      } finally {
        container.dispose();
      }
    });
  });
}

@visibleForTesting
Future<bool> runBackgroundRefreshTask(
  Future<void> Function() refreshTask,
) async {
  try {
    await refreshTask();
    debugPrint('[BackgroundRefresh] completed');
    return true;
  } on Failure catch (error) {
    debugPrint(
      '[BackgroundRefresh] deferred until next interval: '
      '${error.runtimeType} message=${error.message}',
    );
    return true;
  } catch (error, stackTrace) {
    debugPrint('[BackgroundRefresh] unexpected failure: $error');
    if (kDebugMode) {
      debugPrintStack(stackTrace: stackTrace);
    }
    return false;
  }
}
