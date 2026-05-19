import 'package:home_widget/home_widget.dart';

import '../../core/storage/widget_cache.dart';

class WidgetDataWriter {
  WidgetDataWriter._();

  static const String _qualifiedAndroidWidgetName =
      'com.yegamssi.yegamssi.widget.YegamssiWidget';

  static Future<void> update({
    required String weatherCondition,
    required String weatherSymbol,
    required int temperatureCelsius,
    required int feelsLikeCelsius,
    required String fortuneSymbol,
    required int score,
    required String dateLabel,
    required String timeLabel,
    required double latitude,
    required double longitude,
  }) async {
    await Future.wait([
      HomeWidget.saveWidgetData(
        WidgetCacheKeys.weatherCondition,
        weatherCondition,
      ),
      HomeWidget.saveWidgetData(WidgetCacheKeys.weatherSymbol, weatherSymbol),
      HomeWidget.saveWidgetData(
        WidgetCacheKeys.temperature,
        temperatureCelsius,
      ),
      HomeWidget.saveWidgetData(
        WidgetCacheKeys.feelsLikeTemperature,
        feelsLikeCelsius,
      ),
      HomeWidget.saveWidgetData(WidgetCacheKeys.fortuneSymbol, fortuneSymbol),
      HomeWidget.saveWidgetData(WidgetCacheKeys.score, score),
      HomeWidget.saveWidgetData(WidgetCacheKeys.date, dateLabel),
      HomeWidget.saveWidgetData(WidgetCacheKeys.time, timeLabel),
      HomeWidget.saveWidgetData(WidgetCacheKeys.latitude, latitude),
      HomeWidget.saveWidgetData(WidgetCacheKeys.longitude, longitude),
      HomeWidget.saveWidgetData(
        WidgetCacheKeys.updatedAt,
        DateTime.now().toIso8601String(),
      ),
    ]);

    await HomeWidget.updateWidget(
      androidName: 'YegamssiWidget',
      qualifiedAndroidName: _qualifiedAndroidWidgetName,
    );
  }
}
