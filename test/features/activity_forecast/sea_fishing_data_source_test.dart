import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/sea_fishing_data_source.dart';

void main() {
  test('uses only periods intersecting the requested fishing window', () async {
    final source = SeaFishingDataSource(
      dio: _fakeDio([
        _row(period: '오전', index: '좋음'),
        _row(period: '오후', index: '매우나쁨'),
      ]),
    );

    final result = await source.fetch(
      requestedAt: DateTime(2026, 8, 11, 8),
      requestedUntil: DateTime(2026, 8, 11, 11),
      fishingType: '갯바위',
      placeName: '가거도',
    );

    expect(result, isNotNull);
    expect(result!.officialIndex, '좋음');
    expect(result.forecastPeriod, '오전');
  });

  test('selects the worst supported fish when no target is selected', () async {
    final source = SeaFishingDataSource(
      dio: _fakeDio([
        _row(period: '오전', index: '좋음'),
        _row(period: '오전', index: '나쁨', fish: '우럭'),
      ]),
    );

    final result = await source.fetch(
      requestedAt: DateTime(2026, 8, 11, 8),
      requestedUntil: DateTime(2026, 8, 11, 11),
      fishingType: '선상',
      placeName: '가거도',
    );

    expect(result!.officialIndex, '나쁨');
    expect(result.targetFish, '전체 어종 최저');
  });

  test('does not hide missing wind data with another row', () async {
    final source = SeaFishingDataSource(
      dio: _fakeDio([
        _row(period: '오전', index: '보통'),
        _row(period: '오전', index: '좋음')..remove('maxWspd'),
      ]),
    );

    final result = await source.fetch(
      requestedAt: DateTime(2026, 8, 11, 8),
      requestedUntil: DateTime(2026, 8, 11, 11),
      fishingType: '선상',
      placeName: '가거도',
    );

    expect(result!.maxWindSpeedMs, isNull);
    expect(result.maxWaveHeightM, isNull);
  });

  test('uses an official day row for a D+3 to D+6 plan', () async {
    final source = SeaFishingDataSource(
      dio: _fakeDio([_row(period: '일', index: '보통')]),
    );

    final result = await source.fetch(
      requestedAt: DateTime(2026, 8, 15, 16),
      requestedUntil: DateTime(2026, 8, 15, 18),
      fishingType: '갯바위',
      placeName: '가거도',
    );

    expect(result, isNotNull);
    expect(result!.forecastPeriod, '일');
    expect(result.forecastStartsAt, DateTime(2026, 8, 15));
    expect(result.forecastEndsAt, DateTime(2026, 8, 16));
  });

  test('reuses a raw station response when the target fish changes', () async {
    var requestCount = 0;
    final source = SeaFishingDataSource(
      dio: _fakeDio([
        _row(period: '오전', index: '좋음'),
        _row(period: '오전', index: '나쁨', fish: '우럭'),
      ], onRequest: () => requestCount++),
    );

    for (final fish in ['감성돔', '우럭']) {
      await source.fetch(
        requestedAt: DateTime(2026, 8, 11, 8),
        requestedUntil: DateTime(2026, 8, 11, 11),
        fishingType: '갯바위',
        placeName: '가거도',
        targetFish: fish,
      );
    }

    expect(requestCount, 1);
  });
}

Map<String, dynamic> _row({
  required String period,
  required String index,
  String fish = '감성돔',
}) => {
  'seafsPstnNm': '가거도',
  'seafsTgfshNm': fish,
  'predcNoonSeCd': period,
  'totalIndex': index,
  'lat': '34.07308',
  'lot': '125.08805',
  'maxWspd': '5.0',
  'maxWvhgt': '0.8',
  'maxWtem': '22.0',
  'tdlvHrCn': '중조기',
};

Dio _fakeDio(List<Map<String, dynamic>> items, {void Function()? onRequest}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        onRequest?.call();
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            data: {
              'body': {
                'items': {'item': items},
              },
            },
          ),
        );
      },
    ),
  );
  return dio;
}
