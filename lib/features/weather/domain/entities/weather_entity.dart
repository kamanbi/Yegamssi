class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.tempCelsius,
    required this.condition,
    this.precipitationAmountMm,
    this.precipProbability,
    this.windSpeedMs,
  });

  final DateTime time;
  final double tempCelsius;
  final WeatherCondition condition;
  final double? precipitationAmountMm;
  final double? precipProbability;
  final double? windSpeedMs;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.precipProbability,
    this.amPrecipProbability,
    this.pmPrecipProbability,
    this.expectedPrecipitationMm,
    this.amCondition,
    this.pmCondition,
    this.amTempCelsius,
    this.pmTempCelsius,
    this.amTempMinCelsius,
    this.amTempMaxCelsius,
    this.pmTempMinCelsius,
    this.pmTempMaxCelsius,
    this.temperatureAvailable = true,
    this.tempMinAvailable,
    this.tempMaxAvailable,
    this.amTemperatureComplete,
    this.pmTemperatureComplete,
  });

  final DateTime date;
  final double tempMin;
  final double tempMax;
  final WeatherCondition condition;
  final double precipProbability;
  final double? amPrecipProbability;
  final double? pmPrecipProbability;
  final double? expectedPrecipitationMm;
  final WeatherCondition? amCondition;
  final WeatherCondition? pmCondition;
  final double? amTempCelsius;
  final double? pmTempCelsius;
  final double? amTempMinCelsius;
  final double? amTempMaxCelsius;
  final double? pmTempMinCelsius;
  final double? pmTempMaxCelsius;
  final bool temperatureAvailable;
  final bool? tempMinAvailable;
  final bool? tempMaxAvailable;
  final bool? amTemperatureComplete;
  final bool? pmTemperatureComplete;

  bool get hasMinTemperature => tempMinAvailable ?? temperatureAvailable;
  bool get hasMaxTemperature => tempMaxAvailable ?? temperatureAvailable;

  DailyForecast copyWith({
    DateTime? date,
    double? tempMin,
    double? tempMax,
    WeatherCondition? condition,
    double? precipProbability,
    double? amPrecipProbability,
    double? pmPrecipProbability,
    double? expectedPrecipitationMm,
    WeatherCondition? amCondition,
    WeatherCondition? pmCondition,
    double? amTempCelsius,
    double? pmTempCelsius,
    double? amTempMinCelsius,
    double? amTempMaxCelsius,
    double? pmTempMinCelsius,
    double? pmTempMaxCelsius,
    bool? temperatureAvailable,
    bool? tempMinAvailable,
    bool? tempMaxAvailable,
    bool? amTemperatureComplete,
    bool? pmTemperatureComplete,
    bool clearAmCondition = false,
    bool clearPmCondition = false,
    bool clearAmTempCelsius = false,
    bool clearPmTempCelsius = false,
    bool clearAmTempMinCelsius = false,
    bool clearAmTempMaxCelsius = false,
    bool clearPmTempMinCelsius = false,
    bool clearPmTempMaxCelsius = false,
    bool clearExpectedPrecipitationMm = false,
  }) {
    return DailyForecast(
      date: date ?? this.date,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      condition: condition ?? this.condition,
      precipProbability: precipProbability ?? this.precipProbability,
      amPrecipProbability: amPrecipProbability ?? this.amPrecipProbability,
      pmPrecipProbability: pmPrecipProbability ?? this.pmPrecipProbability,
      expectedPrecipitationMm: clearExpectedPrecipitationMm
          ? null
          : (expectedPrecipitationMm ?? this.expectedPrecipitationMm),
      amCondition: clearAmCondition ? null : (amCondition ?? this.amCondition),
      pmCondition: clearPmCondition ? null : (pmCondition ?? this.pmCondition),
      amTempCelsius: clearAmTempCelsius
          ? null
          : (amTempCelsius ?? this.amTempCelsius),
      pmTempCelsius: clearPmTempCelsius
          ? null
          : (pmTempCelsius ?? this.pmTempCelsius),
      amTempMinCelsius: clearAmTempMinCelsius
          ? null
          : (amTempMinCelsius ?? this.amTempMinCelsius),
      amTempMaxCelsius: clearAmTempMaxCelsius
          ? null
          : (amTempMaxCelsius ?? this.amTempMaxCelsius),
      pmTempMinCelsius: clearPmTempMinCelsius
          ? null
          : (pmTempMinCelsius ?? this.pmTempMinCelsius),
      pmTempMaxCelsius: clearPmTempMaxCelsius
          ? null
          : (pmTempMaxCelsius ?? this.pmTempMaxCelsius),
      temperatureAvailable: temperatureAvailable ?? this.temperatureAvailable,
      tempMinAvailable: tempMinAvailable ?? this.tempMinAvailable,
      tempMaxAvailable: tempMaxAvailable ?? this.tempMaxAvailable,
      amTemperatureComplete:
          amTemperatureComplete ?? this.amTemperatureComplete,
      pmTemperatureComplete:
          pmTemperatureComplete ?? this.pmTemperatureComplete,
    );
  }
}

class WeatherEntity {
  const WeatherEntity({
    required this.tempCelsius,
    required this.feelsLikeCelsius,
    required this.condition,
    required this.windSpeedMs,
    required this.precipProbability,
    this.precipitationAmountMm,
    required this.uvIndex,
    required this.humidity,
    required this.observedAt,
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
  final DateTime observedAt;
  final String locationName;
  final double? pm10;
  final double? pm25;
  final double? o3;
  final double? khaiValue;
  final int? khaiGrade;
  final bool isNight;
  final List<HourlyForecast> hourlyForecasts;
  final List<DailyForecast> dailyForecasts;

  double get tempFahrenheit => tempCelsius * 9 / 5 + 32;

  WeatherEntity copyWith({
    double? tempCelsius,
    double? feelsLikeCelsius,
    WeatherCondition? condition,
    double? windSpeedMs,
    double? precipProbability,
    double? precipitationAmountMm,
    int? uvIndex,
    int? humidity,
    DateTime? observedAt,
    String? locationName,
    double? pm10,
    double? pm25,
    double? o3,
    double? khaiValue,
    int? khaiGrade,
    bool? isNight,
    List<HourlyForecast>? hourlyForecasts,
    List<DailyForecast>? dailyForecasts,
    bool clearPrecipitationAmountMm = false,
  }) {
    return WeatherEntity(
      tempCelsius: tempCelsius ?? this.tempCelsius,
      feelsLikeCelsius: feelsLikeCelsius ?? this.feelsLikeCelsius,
      condition: condition ?? this.condition,
      windSpeedMs: windSpeedMs ?? this.windSpeedMs,
      precipProbability: precipProbability ?? this.precipProbability,
      precipitationAmountMm: clearPrecipitationAmountMm
          ? null
          : (precipitationAmountMm ?? this.precipitationAmountMm),
      uvIndex: uvIndex ?? this.uvIndex,
      humidity: humidity ?? this.humidity,
      observedAt: observedAt ?? this.observedAt,
      locationName: locationName ?? this.locationName,
      pm10: pm10 ?? this.pm10,
      pm25: pm25 ?? this.pm25,
      o3: o3 ?? this.o3,
      khaiValue: khaiValue ?? this.khaiValue,
      khaiGrade: khaiGrade ?? this.khaiGrade,
      isNight: isNight ?? this.isNight,
      hourlyForecasts: hourlyForecasts ?? this.hourlyForecasts,
      dailyForecasts: dailyForecasts ?? this.dailyForecasts,
    );
  }
}

enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  hazy,
  windy,
  slightRain,
  rainy,
  heavyRain,
  thunderstorm,
  rainThunder,
  lightSnow,
  snowy,
  sleet,
  hot,
  coldWave,
  unknown,
}
