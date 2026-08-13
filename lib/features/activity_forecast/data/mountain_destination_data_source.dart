import 'package:dio/dio.dart';

import '../../../core/network/weather_proxy_dio.dart';
import '../domain/activity_models.dart';

class MountainDestinationDataSource {
  MountainDestinationDataSource({Dio? dio})
    : _dio = dio ?? WeatherProxyDio.create(WeatherProxyProvider.publicData);

  static const _path = '/1400000/trailInfoService/getforeststoryservice';

  final Dio _dio;

  Future<List<MountainSearchResult>> search(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2) return const [];

    final response = await _dio.get<Map<String, dynamic>>(
      _path,
      queryParameters: {
        '_type': 'json',
        'pageNo': 1,
        'numOfRows': 30,
        'mntnNm': normalizedQuery,
      },
    );
    final body = response.data?['response']?['body'] as Map<String, dynamic>?;
    final rawItems = (body?['items'] as Map<String, dynamic>?)?['item'];
    final items = switch (rawItems) {
      final List<dynamic> values =>
        values.whereType<Map<String, dynamic>>().toList(),
      final Map<String, dynamic> value => [value],
      _ => const <Map<String, dynamic>>[],
    };

    final results = <MountainSearchResult>[];
    final seenIds = <String>{};
    for (final item in items) {
      final id = item['mntnid']?.toString().trim() ?? '';
      final name = item['mntnnm']?.toString().trim() ?? '';
      final address = item['mntninfopoflc']?.toString().trim() ?? '';
      if (id.isEmpty || name.isEmpty || address.isEmpty || !seenIds.add(id)) {
        continue;
      }
      results.add(
        MountainSearchResult(
          id: id,
          name: name,
          address: address,
          heightMeters: int.tryParse(
            item['mntninfohght']?.toString().trim() ?? '',
          ),
        ),
      );
    }
    return results;
  }
}
