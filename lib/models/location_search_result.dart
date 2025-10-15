// import 'package:nowa_runtime/nowa_runtime.dart';

// @NowaGenerated()
// class LocationSearchResult {
//   const LocationSearchResult({
//     required this.placeId,
//     required this.name,
//     required this.address,
//     required this.latitude,
//     required this.longitude,
//   });

//   factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
//     return LocationSearchResult(
//       placeId: json['place_id'] as String,
//       name: json['name'] as String,
//       address: json['formatted_address'] as String,
//       latitude: json['geometry']['location']['lat'] as double,
//       longitude: json['geometry']['location']['lng'] as double,
//     );
//   }

//   final String placeId;

//   final String name;

//   final String address;

//   final double latitude;

//   final double longitude;

//   Map<String, dynamic> toJson() {
//     return {
//       'place_id': placeId,
//       'name': name,
//       'formatted_address': address,
//       'geometry': {
//         'location': {'lat': latitude, 'lng': longitude},
//       },
//     };
//   }
// }


import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class LocationSearchResult {
  const LocationSearchResult({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  /// **CORRECTED** factory for parsing a Geoapify JSON feature.
  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    // Geoapify nests the useful data inside a 'properties' object.
    final properties = json['properties'] as Map<String, dynamic>;

    return LocationSearchResult(
      placeId: properties['place_id'] as String? ?? properties['formatted'] as String,
      name: properties['name'] as String? ?? properties['address_line1'] as String,
      address: properties['formatted'] as String,
      latitude: properties['lat'] as double,
      longitude: properties['lon'] as double,
    );
  }

  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  // No changes needed for toJson, but it's good practice
  // to keep it consistent if you ever need it.
  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'formatted': address, // Geoapify uses 'formatted'
      'lat': latitude,
      'lon': longitude,
    };
  }
}