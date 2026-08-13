import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum ActivityForecastAvailability { checking, eligible, ineligible }

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

final activityForecastAvailabilityProvider =
    FutureProvider<ActivityForecastAvailability>((ref) async {
      final location = await ref.watch(verifiedKoreanLocationProvider.future);
      return location != null
          ? ActivityForecastAvailability.eligible
          : ActivityForecastAvailability.ineligible;
    });
