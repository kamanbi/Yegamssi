import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yegamssi/core/storage/weather_snapshot_cache_codec.dart';
import 'package:yegamssi/features/weather/data/models/weather_response.dart';
import 'package:yegamssi/features/weather/data/sources/kma_data_source.dart';
import 'package:yegamssi/features/weather/domain/day_part_temperature_policy.dart';
import 'package:yegamssi/features/weather/domain/entities/weather_entity.dart';

Map<String, dynamic> item(String day, int hour, String category, num value) => {
  'fcstDate': day,
  'fcstTime': '${hour.toString().padLeft(2, '0')}00',
  'category': category,
  'fcstValue': '$value',
};

List<Map<String, dynamic>> history() => [
  for (var hour = 0; hour < 24; hour++) ...[
    item('20261005', hour, 'TMP', hour < 12 ? 15 + hour % 4 : 20 - hour % 3),
    item('20261005', hour, 'SKY', hour < 12 ? 4 : 1),
  ],
  item('20261005', 6, 'TMN', 15),
  item('20261005', 15, 'TMX', 20),
];

List<Map<String, dynamic>> partialLatest() => [
  for (var hour = 18; hour < 24; hour++) item('20261005', hour, 'TMP', 19),
  for (final hour in [0, 3, 6, 9, 12]) ...[
    item('20261009', hour, 'TMP', hour == 12 ? 23 : 13 + hour % 5),
    item('20261009', hour, 'SKY', 1),
  ],
  item('20261009', 6, 'TMN', 13),
];

class FixtureApi {
  final requests = <RequestOptions>[];
  bool failHistory = false;
  bool failPreviousTemperature = false;
  final Dio dio = Dio();

  FixtureApi() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          requests.add(request);
          Object data;
          if (request.path.endsWith('getVilageFcst')) {
            if (failHistory) {
              handler.reject(
                DioException(
                  requestOptions: request,
                  type: DioExceptionType.connectionError,
                ),
              );
              return;
            }
            data = {
              'response': {
                'body': {
                  'items': {'item': history()},
                },
              },
            };
          } else if (request.path.endsWith('getMidLandFcst')) {
            // At 18:00 the response has no Friday (day 4) entry at all.
            data = {
              'response': {
                'body': {
                  'items': {
                    'item': [
                      {
                        'regId': '11B00000',
                        for (final day in [5, 6, 7]) ...{
                          'wf${day}Am': '맑음',
                          'wf${day}Pm': '맑음',
                        },
                      },
                    ],
                  },
                },
              },
            };
          } else if (request.path.endsWith('fct_afs_wc.php')) {
            final previous = request.queryParameters['tmfc1'] == '2026100506';
            if (previous && failPreviousTemperature) {
              handler.reject(
                DioException(
                  requestOptions: request,
                  type: DioExceptionType.connectionError,
                ),
              );
              return;
            }
            data = previous
                ? '11B20201 202610050600 202610090000 A01 109 2 13 25\n'
                      '11B20201 202610050600 202610100000 A01 109 2 14 24\n'
                : '11B20201 202610051800 202610100000 A01 109 2 14 25\n'
                      '11B20201 202610051800 202610110000 A01 109 2 15 26\n'
                      '11B20201 202610051800 202610120000 A01 109 2 16 26\n';
          } else {
            throw StateError('Unexpected API ${request.path}');
          }
          handler.resolve(
            Response(requestOptions: request, data: data, statusCode: 200),
          );
        },
      ),
    );
  }

  int get historyCalls =>
      requests.where((r) => r.path.endsWith('getVilageFcst')).length;
  int get previousCalls =>
      requests.where((r) => r.queryParameters['tmfc1'] == '2026100506').length;

  Future<List<DailyForecast>> load({
    List<Map<String, dynamic>>? latest,
    ({double lat, double lon}) position = (lat: 37.5, lon: 126.7),
  }) => KmaDataSource(dio: dio).loadDailyForecasts(
    latestItems: latest ?? partialLatest(),
    position: position,
    now: DateTime(2026, 10, 5, 19),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'cold evening launch restores full morning and latest evening by hour',
    () async {
      final api = FixtureApi();
      final days = await api.load();
      final today = days.singleWhere((day) => day.date.day == 5);
      expect(today.amTempMinCelsius, 15);
      expect(today.amTempMaxCelsius, 18);
      expect(today.amCondition, WeatherCondition.cloudy);
      expect(today.amTemperatureComplete, isTrue);
      expect(today.pmTemperatureComplete, isTrue);
      expect(today.pmTempMinCelsius, 18);
      expect(today.pmTempMaxCelsius, 20);
      expect(today.tempMin, 15);
      expect(today.tempMax, 20);
      expect(api.historyCalls, 1);
      final historyRequest = api.requests.firstWhere(
        (r) => r.path.endsWith('getVilageFcst'),
      );
      expect(historyRequest.queryParameters['base_date'], '20261004');
      expect(historyRequest.queryParameters['base_time'], '2300');
    },
  );

  test(
    'Friday missing in latest midterm is restored and partial PM supplements',
    () async {
      final api = FixtureApi();
      final days = await api.load();
      final friday = days.singleWhere((day) => day.date.day == 9);
      expect(friday.tempMin, 13);
      expect(friday.tempMax, 25);
      expect(friday.temperatureAvailable, isTrue);
      expect(friday.condition, WeatherCondition.sunny);
      expect(friday.amTemperatureComplete, isTrue);
      expect(friday.pmTemperatureComplete, isFalse);
      expect(
        DayPartTemperaturePolicy.shouldSupplement(friday, morning: false),
        isTrue,
      );
      expect(
        DayPartTemperaturePolicy.shouldSupplement(friday, morning: true),
        isFalse,
      );
      expect(days.singleWhere((day) => day.date.day == 10).tempMax, 25);
      expect(api.previousCalls, 1);
    },
  );

  test(
    'same-grid history survives new source instance without repeating request',
    () async {
      final api = FixtureApi();
      await api.load();
      api.failHistory = true;
      final days = await api.load();
      expect(api.historyCalls, 1);
      expect(days.first.amTemperatureComplete, isTrue);
    },
  );

  test('another grid cannot reuse current location history', () async {
    final api = FixtureApi();
    await api.load();
    await api.load(position: (lat: 35.1, lon: 129.0));
    expect(api.historyCalls, 2);
  });

  test(
    'later refresh retains revised morning after it disappears upstream',
    () async {
      final api = FixtureApi();
      await api.load(
        latest: [
          ...history(),
          item('20261005', 9, 'TMP', 21),
          item('20261005', 15, 'TMX', 23),
        ],
      );
      final days = await api.load();
      expect(days.first.amTempMaxCelsius, 21);
      expect(days.first.tempMax, 23);
      expect(api.historyCalls, 0);
    },
  );

  test(
    'fully covered data needs no history or previous-midterm request',
    () async {
      final api = FixtureApi();
      await api.load(latest: history());
      expect(api.historyCalls, 0);
      expect(api.previousCalls, 0);
    },
  );

  test(
    'today is recovered even when latest forecast has no today rows',
    () async {
      final api = FixtureApi();
      final days = await api.load(
        latest: partialLatest()
            .where((row) => row['fcstDate'] != '20261005')
            .toList(),
      );
      expect(days.first.date.day, 5);
      expect(days.first.amTemperatureComplete, isTrue);
    },
  );

  test(
    'upstream failure keeps valid data and does not invent missing extremes',
    () async {
      final api = FixtureApi()
        ..failHistory = true
        ..failPreviousTemperature = true;
      final days = await api.load();
      final friday = days.singleWhere((day) => day.date.day == 9);
      expect(friday.hasMinTemperature, isTrue);
      expect(friday.hasMaxTemperature, isFalse);
      expect(days.first.amTempMinCelsius, isNull);
      expect(api.historyCalls, 1);
      expect(api.previousCalls, 1);
    },
  );

  test('coverage survives response conversion and persisted cache', () async {
    final days = await FixtureApi().load();
    final entity = WeatherResponse(
      tempCelsius: 19,
      feelsLikeCelsius: 19,
      condition: WeatherCondition.sunny,
      windSpeedMs: 1,
      precipProbability: 0,
      uvIndex: 0,
      humidity: 50,
      locationName: 'test',
      dailyForecasts: days,
    ).toEntity();
    final decoded = WeatherSnapshotCacheCodec.fromJson(
      WeatherSnapshotCacheCodec.toJson(entity),
    );
    expect(decoded.dailyForecasts.first.amTemperatureComplete, isTrue);
    expect(
      decoded.dailyForecasts
          .singleWhere((d) => d.date.day == 9)
          .pmTemperatureComplete,
      isFalse,
    );
  });

  test(
    'constant complete temperatures are valid, multiple incomplete samples are not',
    () {
      expect(
        DayPartTemperaturePolicy.isComplete([0, 3, 6, 9], morning: true),
        isTrue,
      );
      expect(
        DayPartTemperaturePolicy.isComplete([12, 13, 14], morning: false),
        isFalse,
      );
      final daily = DailyForecast(
        date: DateTime(2026, 10, 9),
        tempMin: 13,
        tempMax: 25,
        condition: WeatherCondition.sunny,
        precipProbability: 0,
        amTempMinCelsius: 15,
        amTempMaxCelsius: 15,
        amTemperatureComplete: true,
      );
      expect(
        DayPartTemperaturePolicy.shouldSupplement(daily, morning: true),
        isFalse,
      );
    },
  );
}
