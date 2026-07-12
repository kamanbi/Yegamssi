import '../../features/weather/domain/entities/weather_entity.dart';

class RefreshPolicy {
  const RefreshPolicy._();

  static const weatherRefreshInterval = Duration(minutes: 30);
  static const widgetRefreshInterval = Duration(minutes: 30);
  static const cacheDisplayTtl = Duration(hours: 1);
  static const forecastCutoffGrace = Duration(minutes: 5);
  static const networkTimeout = Duration(seconds: 12);

  static const dayStartHour = 6;
  static const nightStartHour = 20;

  static bool isWeatherRefreshDue(
    WeatherEntity? cachedWeather, {
    bool force = false,
    DateTime? now,
  }) {
    if (force) return true;
    if (cachedWeather == null) return true;

    final effectiveNow = now ?? DateTime.now();
    return effectiveNow.difference(cachedWeather.observedAt) >=
        weatherRefreshInterval;
  }

  static bool isDisplayCacheFresh(WeatherEntity weather, {DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    return effectiveNow.difference(weather.observedAt) <= cacheDisplayTtl;
  }

  static bool isNightByHour(DateTime time) {
    return time.hour < dayStartHour || time.hour >= nightStartHour;
  }
}
