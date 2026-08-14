import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/storage/local_storage.dart';

enum ActivityForecastAvailability { checking, eligible, ineligible }

const _activityAvailabilityCacheKey = 'activity_forecast_availability_cached';

class VerifiedKoreanLocation {
  const VerifiedKoreanLocation({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  final double latitude;
  final double longitude;
  final String locationName;
}

final verifiedKoreanLocationProvider = FutureProvider<VerifiedKoreanLocation?>((
  ref,
) async {
  if (!await Geolocator.isLocationServiceEnabled()) return null;

  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    ).timeout(const Duration(seconds: 5));
    final placemark = placemarks.firstOrNull;
    if (placemark?.isoCountryCode?.toUpperCase() != 'KR') return null;
    final locationName = [
      placemark?.administrativeArea,
      placemark?.locality,
      placemark?.subLocality,
    ].whereType<String>().where((value) => value.isNotEmpty).toSet().join(' ');
    return VerifiedKoreanLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: locationName.isEmpty ? '현재 위치' : locationName,
    );
  } catch (_) {
    return null;
  }
});

/// 앱 시작 시 GPS·역지오코딩 확인(최대 15초)이 끝나기 전까지 "활동예감" 탭이
/// 하단 네비게이션에서 사라져 보이는 문제를 줄이기 위해, 지난번 확인 결과를
/// SharedPreferences에 캐시해두고 우선 그 값으로 즉시 렌더링한다. 실제 GPS
/// 확인은 그대로 백그라운드에서 진행되고, 결과가 나오면 최신 값으로 갱신 +
/// 캐시를 덮어쓴다.
final activityForecastAvailabilityProvider =
    StreamProvider<ActivityForecastAvailability>((ref) async* {
      final cached = await LocalStorage.getBool(_activityAvailabilityCacheKey);
      if (cached != null) {
        yield cached
            ? ActivityForecastAvailability.eligible
            : ActivityForecastAvailability.ineligible;
      }

      final location = await ref.read(verifiedKoreanLocationProvider.future);
      final resolved = location != null
          ? ActivityForecastAvailability.eligible
          : ActivityForecastAvailability.ineligible;
      await LocalStorage.setBool(
        _activityAvailabilityCacheKey,
        resolved == ActivityForecastAvailability.eligible,
      );
      yield resolved;
    });
