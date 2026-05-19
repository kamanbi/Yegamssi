import '../entities/weather_entity.dart';
import '../../../../core/error/failure.dart';

typedef WeatherResult = ({WeatherEntity? data, Failure? error});

abstract interface class WeatherRepository {
  Future<WeatherResult> getCurrentWeather({
    required double lat,
    required double lon,
  });
}
