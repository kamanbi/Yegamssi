import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/activity_models.dart';

class FishingDestinationCatalog {
  FishingDestinationCatalog({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/data/activity/fishing_ports_20260811.json';
  static const catalogVersion = '2026-08-11';
  static const officialStationsAssetPath =
      'assets/data/activity/official_fishing_stations_20260811.json';
  static const officialStationsCatalogVersion = '2026-08-11';

  final AssetBundle _bundle;
  Future<List<ActivityDestination>>? _cachedDestinations;
  Future<Map<String, List<ActivityDestination>>>? _cachedOfficialStations;

  Future<List<ActivityDestination>> load() {
    return _cachedDestinations ??= _loadAsset();
  }

  Future<List<ActivityDestination>> loadOfficialIndexStations(
    String fishingType,
  ) async {
    final stationsByType = await (_cachedOfficialStations ??=
        _loadOfficialStationsAsset());
    return stationsByType[fishingType] ?? const [];
  }

  Future<List<ActivityDestination>> _loadAsset() async {
    final raw = await _bundle.loadString(assetPath);
    return decode(raw);
  }

  Future<Map<String, List<ActivityDestination>>>
  _loadOfficialStationsAsset() async {
    final raw = await _bundle.loadString(officialStationsAssetPath);
    return decodeOfficialStations(raw);
  }

  static List<ActivityDestination> decode(String raw) {
    final document = jsonDecode(raw) as Map<String, dynamic>;
    if (document['schemaVersion'] != 2 ||
        document['catalogVersion'] != catalogVersion) {
      throw const FormatException('지원하지 않는 공식 어항 카탈로그입니다.');
    }

    final source = document['source'] as String? ?? '';
    final items = (document['items'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => _destinationFromJson(item, source))
        .toList(growable: false);
    if (items.isEmpty) {
      throw const FormatException('공식 어항 카탈로그가 비어 있습니다.');
    }
    if (items.map((item) => item.id).toSet().length != items.length) {
      throw const FormatException('공식 어항 카탈로그 ID가 중복됩니다.');
    }
    return items;
  }

  static Map<String, List<ActivityDestination>> decodeOfficialStations(
    String raw,
  ) {
    final document = jsonDecode(raw) as Map<String, dynamic>;
    if (document['schemaVersion'] != 1 ||
        document['catalogVersion'] != officialStationsCatalogVersion) {
      throw const FormatException('지원하지 않는 공식 낚시 지점 목록입니다.');
    }

    final source = document['source'] as String? ?? '';
    final stationsByType = <String, List<ActivityDestination>>{
      '갯바위': [],
      '선상': [],
    };
    for (final item
        in (document['items'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()) {
      final latitude = (item['latitude'] as num).toDouble();
      final longitude = (item['longitude'] as num).toDouble();
      if (!_isKoreanCoordinate(latitude, longitude)) {
        throw FormatException('대한민국 범위를 벗어난 공식 낚시 지점입니다: ${item['id']}');
      }
      final supportedOptions =
          item['supportedOptions'] as Map<String, dynamic>? ?? const {};
      for (final fishingType in stationsByType.keys) {
        final options =
            (supportedOptions[fishingType] as List<dynamic>? ?? const [])
                .whereType<String>()
                .toList(growable: false);
        stationsByType[fishingType]!.add(
          ActivityDestination(
            id: item['id'] as String,
            name: item['name'] as String,
            areaName: '$fishingType · 공식 바다낚시지수 지원',
            latitude: latitude,
            longitude: longitude,
            source: source,
            kind: ActivityDestinationKind.officialIndexStation,
            supportedOptions: options,
          ),
        );
      }
    }

    for (final entry in stationsByType.entries) {
      if (entry.value.isEmpty ||
          entry.value.map((item) => item.id).toSet().length !=
              entry.value.length) {
        throw FormatException('${entry.key} 공식 낚시 지점 목록이 비었거나 ID가 중복됩니다.');
      }
    }
    return stationsByType;
  }

  static List<ActivityDestination> merge({
    required List<ActivityDestination> officialFishingPorts,
    required List<ActivityDestination> officialIndexStations,
  }) {
    final destinationsById = <String, ActivityDestination>{};
    for (final destination in officialFishingPorts) {
      destinationsById[destination.id] = destination;
    }
    for (final destination in officialIndexStations) {
      destinationsById[destination.id] = destination;
    }

    final destinations = destinationsById.values.toList(growable: false);
    destinations.sort((left, right) {
      final kindOrder = _kindOrder(left.kind).compareTo(_kindOrder(right.kind));
      return kindOrder != 0 ? kindOrder : left.name.compareTo(right.name);
    });
    return destinations;
  }

  Future<ActivityDestination?> resolveSavedDestination(
    ActivityJudgmentRequest request,
  ) async {
    if (request.destinationKind !=
            ActivityDestinationKind.officialFishingPort &&
        !request.destinationId.startsWith('mof-port:') &&
        !request.destinationId.startsWith('fipa-port:')) {
      return null;
    }

    final destinations = await load();
    for (final destination in destinations) {
      if (destination.id == request.destinationId) return destination;
    }

    final legacyName = request.destinationId.startsWith('mof-port:')
        ? request.destinationId.substring('mof-port:'.length)
        : request.locationName;
    if (_normalizedName(legacyName) == _normalizedName('득암항')) return null;

    final candidates = destinations
        .where((destination) {
          final names = [
            destination.name,
            destination.officialName,
            ...destination.aliases,
          ].map(_normalizedName);
          return names.contains(_normalizedName(legacyName)) ||
              names.contains(_normalizedName(request.locationName));
        })
        .toList(growable: false);
    if (candidates.isEmpty) return null;
    candidates.sort(
      (left, right) => _distanceSquared(
        left,
        request,
      ).compareTo(_distanceSquared(right, request)),
    );
    return candidates.first;
  }

  static ActivityDestination _destinationFromJson(
    Map<String, dynamic> json,
    String source,
  ) {
    final latitude = (json['latitude'] as num).toDouble();
    final longitude = (json['longitude'] as num).toDouble();
    if (!_isKoreanCoordinate(latitude, longitude)) {
      throw FormatException('대한민국 범위를 벗어난 공식 어항 좌표입니다: ${json['id']}');
    }
    return ActivityDestination(
      id: json['id'] as String,
      name: json['displayName'] as String,
      officialName: json['officialName'] as String,
      areaName: json['address'] as String,
      latitude: latitude,
      longitude: longitude,
      source: source,
      kind: ActivityDestinationKind.officialFishingPort,
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }

  static double _distanceSquared(
    ActivityDestination destination,
    ActivityJudgmentRequest request,
  ) {
    final latitudeDelta = destination.latitude - request.latitude;
    final longitudeDelta = destination.longitude - request.longitude;
    return latitudeDelta * latitudeDelta + longitudeDelta * longitudeDelta;
  }

  static bool _isKoreanCoordinate(double latitude, double longitude) {
    return latitude >= 32 &&
        latitude <= 39.5 &&
        longitude >= 123 &&
        longitude <= 132;
  }

  static String _normalizedName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  static int _kindOrder(ActivityDestinationKind kind) => switch (kind) {
    ActivityDestinationKind.officialIndexStation => 0,
    ActivityDestinationKind.officialFishingPort => 1,
    ActivityDestinationKind.customLocation => 2,
    ActivityDestinationKind.mountain => 3,
  };
}
