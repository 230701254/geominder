import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geominder/models/location_search_result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  factory LocationService() => _instance;
  LocationService._internal();
  static final LocationService _instance = LocationService._internal();

  final String _apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? 'MISSING_API_KEY';

  Future<List<LocationSearchResult>> searchPlaces(String query) async {
    if (_apiKey == 'MISSING_API_KEY') {
      throw Exception('API Key is missing. Check your .env file.');
    }
    if (query.length < 3) {
      return [];
    }

    final uri = Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete?text=$query&apiKey=$_apiKey');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch locations from Geoapify.');
    }

    final data = json.decode(response.body);

    return (data['features'] as List).map((feature) {
      final properties = feature['properties'];
      return LocationSearchResult(
        placeId: properties['place_id'] ?? properties['formatted'],
        name: properties['name'] ?? properties['address_line1'],
        address: properties['formatted'],
        latitude: properties['lat'],
        longitude: properties['lon'],
      );
    }).toList();
  }
}