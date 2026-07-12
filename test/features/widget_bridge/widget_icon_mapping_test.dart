import 'package:flutter_test/flutter_test.dart';

import 'package:yegamssi/core/constants/app_assets.dart';
import 'package:yegamssi/features/weather/domain/entities/weather_entity.dart';
import 'package:yegamssi/features/weather/presentation/widgets/weather_icon_mapper.dart';
import 'package:yegamssi/features/widget_bridge/widget_snapshot_sync.dart';

void main() {
  group('weather icon mapping', () {
    test('uses the moon-and-cloud icon for cloudy night in the app', () {
      expect(
        WeatherIconMapper.assetFor(WeatherCondition.cloudy, isNight: true),
        AppAssets.weatherCloudyNight,
      );
    });

    test('keeps widget condition keys distinct for night cloud states', () {
      expect(
        widgetConditionKeyFor(WeatherCondition.cloudy, true),
        'cloudy_night',
      );
      expect(
        widgetConditionKeyFor(WeatherCondition.partlyCloudy, true),
        'partlyCloudy_night',
      );
      expect(widgetConditionKeyFor(WeatherCondition.cloudy, false), 'cloudy');
    });
  });
}
