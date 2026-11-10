import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/core/locale/country_code.dart';
import 'package:yegamssi/core/locale/country_resolver.dart';
import 'package:yegamssi/core/utils/location_provider.dart';
import 'package:yegamssi/features/weather/data/sources/supplemental_temperature_source.dart';
import 'package:yegamssi/features/weather/presentation/supplemental_temperature_provider.dart';

class RecoveringTemperatureSource extends SupplementalTemperatureSource {
  int calls = 0;

  @override
  Future<Map<String, SupplementalDay>> load(
    ({double lat, double lon}) position, {
    required bool Function() isActive,
  }) async {
    calls++;
    if (calls == 1) throw StateError('temporary outage');
    return {'2026-10-19': (am: (min: 11.8, max: 13.3), pm: null)};
  }
}

void main() {
  testWidgets('failed supplement retries and refresh/resume reloads it', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final source = RecoveringTemperatureSource();
    final container = ProviderContainer(
      overrides: [
        resolvedCountryProvider.overrideWith((ref) async => CountryCode.kr),
        currentPositionProvider.overrideWith(
          (ref) async => (lat: 37.55, lon: 126.65),
        ),
        supplementalTemperatureSourceProvider.overrideWithValue(source),
      ],
    );
    final subscription = container.listen(
      supplementalTemperatureProvider,
      (_, _) {},
    );
    try {
      await expectLater(
        container.read(supplementalTemperatureProvider.future),
        throwsStateError,
      );
      await tester.pump(const Duration(seconds: 31));
      final recovered = await container.read(
        supplementalTemperatureProvider.future,
      );
      expect(recovered['2026-10-19']!.am, (min: 11.8, max: 13.3));
      expect(source.calls, 2);

      container.invalidate(supplementalTemperatureProvider);
      await tester.pump(const Duration(milliseconds: 1));
      await container.read(supplementalTemperatureProvider.future);
      expect(source.calls, 3);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(milliseconds: 1));
      await container.read(supplementalTemperatureProvider.future);
      expect(source.calls, 4);
    } finally {
      subscription.close();
      container.dispose();
    }
    await tester.pump(const Duration(milliseconds: 1));
  });
}
