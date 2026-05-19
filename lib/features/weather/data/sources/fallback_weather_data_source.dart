import '../../../../core/error/app_exception.dart';
import 'weather_data_source.dart';
import '../models/weather_response.dart';

/// Tries multiple weather providers in order until one succeeds.
class FallbackWeatherDataSource implements WeatherDataSource {
  const FallbackWeatherDataSource(this._sources);

  final List<WeatherDataSource> _sources;

  @override
  Future<WeatherResponse> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    AppException? lastAppException;
    Object? lastError;

    for (final source in _sources) {
      try {
        return await source.fetchCurrent(lat: lat, lon: lon);
      } on AppException catch (error) {
        lastAppException = error;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastAppException != null) throw lastAppException;
    throw lastError ?? const ServerException('날씨 소스를 모두 시도했지만 실패했습니다');
  }
}
