import 'dart:convert';

class SavedLocation {
  const SavedLocation({
    required this.name,
    required this.lat,
    required this.lon,
  });

  final String name;
  final double lat;
  final double lon;

  Map<String, dynamic> toJson() => {
        'name': name,
        'lat': lat,
        'lon': lon,
      };

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
        name: json['name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lon: (json['lon'] as num).toDouble(),
      );

  static List<SavedLocation> listFromJsonString(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => SavedLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJsonString(List<SavedLocation> locations) =>
      jsonEncode(locations.map((e) => e.toJson()).toList());

  @override
  bool operator ==(Object other) =>
      other is SavedLocation &&
      other.name == name &&
      other.lat == lat &&
      other.lon == lon;

  @override
  int get hashCode => Object.hash(name, lat, lon);
}
