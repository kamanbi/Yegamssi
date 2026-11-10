import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/country_code.dart';
import '../../../core/locale/country_resolver.dart';
import '../../../core/utils/location_provider.dart';
import '../data/sources/supplemental_temperature_source.dart';
import 'weather_location_provider.dart';

final supplementalTemperatureSourceProvider = Provider(
  (ref) => SupplementalTemperatureSource(),
);

class _SupplementalResumeObserver extends WidgetsBindingObserver {
  _SupplementalResumeObserver(this.onResume);

  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}

// Watched exclusively by the weather screen, never background/score/widget code.
final supplementalTemperatureProvider =
    FutureProvider.autoDispose<Map<String, SupplementalDay>>((ref) async {
      const retryInterval = Duration(seconds: 30);
      var active = true;
      Timer? retryTimer;
      final observer = _SupplementalResumeObserver(ref.invalidateSelf);
      WidgetsBinding.instance.addObserver(observer);
      ref.onDispose(() {
        active = false;
        retryTimer?.cancel();
        WidgetsBinding.instance.removeObserver(observer);
      });
      void scheduleRetry() {
        if (!active) return;
        retryTimer = Timer(retryInterval, () {
          if (active &&
              WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed) {
            ref.invalidateSelf();
          }
        });
      }

      final selected = ref.watch(
        weatherLocationNotifierProvider.select((state) => state.location),
      );
      final country = await ref.watch(resolvedCountryProvider.future);
      if (country != CountryCode.kr) return const {};
      final position = selected == null
          ? await ref.watch(currentPositionProvider.future)
          : (lat: selected.lat, lon: selected.lon);
      if (position.lat < 33 ||
          position.lat > 39 ||
          position.lon < 124 ||
          position.lon > 132) {
        return const {};
      }
      if (!active) return const {};
      try {
        final result = await ref
            .read(supplementalTemperatureSourceProvider)
            .load(position, isActive: () => active);
        if (result.isEmpty) scheduleRetry();
        return result;
      } catch (_) {
        scheduleRetry();
        rethrow;
      }
    });
