import '../../domain/entities/weather_entity.dart';

class WeatherResponse {
  const WeatherResponse({
    required this.tempCelsius,
    required this.feelsLikeCelsius,
    required this.condition,
    required this.windSpeedMs,
    required this.precipProbability,
    this.precipitationAmountMm,
    required this.uvIndex,
    required this.humidity,
    required this.locationName,
    this.pm10,
    this.pm25,
    this.o3,
    this.khaiValue,
    this.khaiGrade,
    this.isNight = false,
    this.hourlyForecasts = const [],
    this.dailyForecasts = const [],
  });

  final double tempCelsius;
  final double feelsLikeCelsius;
  final WeatherCondition condition;
  final double windSpeedMs;
  final double precipProbability;
  final double? precipitationAmountMm;
  final int uvIndex;
  final int humidity;
  final String locationName;
  final double? pm10;
  final double? pm25;
  final double? o3;
  final double? khaiValue;
  final int? khaiGrade;
  final bool isNight;
  final List<HourlyForecast> hourlyForecasts;
  final List<DailyForecast> dailyForecasts;

  WeatherEntity toEntity() {
    return WeatherEntity(
      tempCelsius: tempCelsius,
      feelsLikeCelsius: feelsLikeCelsius,
      condition: _applyTempOverrides(condition, tempCelsius),
      windSpeedMs: windSpeedMs,
      precipProbability: precipProbability,
      precipitationAmountMm: precipitationAmountMm,
      uvIndex: uvIndex,
      humidity: humidity,
      observedAt: DateTime.now(),
      locationName: locationName,
      pm10: pm10,
      pm25: pm25,
      o3: o3,
      khaiValue: khaiValue,
      khaiGrade: khaiGrade,
      isNight: isNight,
      hourlyForecasts: hourlyForecasts
          .map(
            (forecast) => HourlyForecast(
              time: forecast.time,
              tempCelsius: forecast.tempCelsius,
              condition: _applyTempOverrides(
                forecast.condition,
                forecast.tempCelsius,
              ),
            ),
          )
          .toList(growable: false),
      dailyForecasts: dailyForecasts
          .map(
            (forecast) => DailyForecast(
              date: forecast.date,
              tempMin: forecast.tempMin,
              tempMax: forecast.tempMax,
              condition: _applyTempOverrides(
                forecast.condition,
                forecast.tempMax,
                minTemp: forecast.tempMin,
              ),
              precipProbability: forecast.precipProbability,
              expectedPrecipitationMm: forecast.expectedPrecipitationMm,
              amCondition: forecast.amCondition == null
                  ? null
                  : _applyTempOverrides(
                      forecast.amCondition!,
                      forecast.amTempCelsius ?? forecast.tempMin,
                      minTemp: forecast.tempMin,
                    ),
              pmCondition: forecast.pmCondition == null
                  ? null
                  : _applyTempOverrides(
                      forecast.pmCondition!,
                      forecast.pmTempCelsius ?? forecast.tempMax,
                      minTemp: forecast.tempMin,
                    ),
              amTempCelsius: forecast.amTempCelsius,
              pmTempCelsius: forecast.pmTempCelsius,
            ),
          )
          .toList(growable: false),
    );
  }

  static WeatherCondition _applyTempOverrides(
    WeatherCondition base,
    double temp, {
    double? minTemp,
  }) {
    const benignConditions = {
      WeatherCondition.sunny,
      WeatherCondition.partlyCloudy,
      WeatherCondition.cloudy,
      WeatherCondition.hazy,
      WeatherCondition.windy,
      WeatherCondition.unknown,
    };
    if (!benignConditions.contains(base)) {
      return base;
    }
    if (temp >= 33) {
      return WeatherCondition.hot;
    }
    final lowTemperature = minTemp ?? temp;
    if (lowTemperature <= -10) {
      return WeatherCondition.coldWave;
    }
    return base;
  }
}
