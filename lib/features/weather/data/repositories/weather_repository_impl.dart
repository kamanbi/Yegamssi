import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/weather_repository.dart';
import '../sources/weather_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl(this._dataSource);

  final WeatherDataSource _dataSource;

  @override
  Future<WeatherResult> getCurrentWeather({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _dataSource.fetchCurrent(lat: lat, lon: lon);
      return (data: response.toEntity(), error: null);
    } on NetworkException catch (e) {
      return (data: null, error: NetworkFailure(e.message));
    } on ServerException catch (e) {
      return (data: null, error: ServerFailure(e.message));
    } catch (e) {
      return (data: null, error: UnknownFailure(e.toString()));
    }
  }
}
