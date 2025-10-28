import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final String _apiKey = 'f4be9016fe6548249e2ef2471cc60b04';

  final MapController _mapController = MapController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  LatLng? _selectedLocation;
  double _radius = 500.0;
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedLocation!, 15.0);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get location. Enable GPS.')),
      );
    }
  }

  void _searchPlaces(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      if (query.trim().length < 3) return;

      setState(() => _isLoading = true);

      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/search?text=$query&apiKey=$_apiKey',
      );

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final body = json.decode(response.body);
          setState(() => _searchResults = body['features']);
        } else {
          throw Exception('Geoapify error');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching locations: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Alarm Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: (_selectedLocation == null || _nameController.text.trim().isEmpty)
                ? null
                : () {
                    final newAlarm = AlarmModel(
                      id: const Uuid().v4(),
                      name: _nameController.text.trim(),
                      latitude: _selectedLocation!.latitude,
                      longitude: _selectedLocation!.longitude,
                      radius: _radius,
                    );
                    Navigator.of(context).pop(newAlarm);
                  },
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 🗺️ Map View
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation ?? const LatLng(13.0827, 80.2707),
                initialZoom: 13,
                onTap: (_, location) {
                  setState(() {
                    _selectedLocation = location;
                    _searchResults = [];
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: isDark
                      ? 'https://maps.geoapify.com/v1/tile/dark-matter/{z}/{x}/{y}.png?apiKey=$_apiKey'
                      : 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$_apiKey',
                  additionalOptions: {'apiKey': _apiKey},
                ),
                if (_selectedLocation != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _selectedLocation!,
                        radius: _radius,
                        useRadiusInMeter: true,
                        color: Colors.deepPurpleAccent.withOpacity(0.25),
                        borderColor: Colors.deepPurpleAccent,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                      ),
                    ],
                  ),
              ],
            ),

            // 🔍 Search Bar
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(30),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchPlaces,
                      decoration: InputDecoration(
                        hintText: 'Search for a place...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchResults = []);
                                },
                              ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 200,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final place = _searchResults[index]['properties'];
                          return ListTile(
                            title: Text(place['formatted'] ?? 'Unknown Place'),
                            onTap: () {
                              final lat = place['lat'];
                              final lon = place['lon'];
                              setState(() {
                                _selectedLocation = LatLng(lat, lon);
                                _mapController.move(_selectedLocation!, 15);
                                _searchController.clear();
                                _searchResults = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ⚙️ Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: isDark ? Colors.black87 : Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Alarm Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Radius'),
                        Text('${_radius.toInt()} m'),
                      ],
                    ),
                    Slider(
                      activeColor: Colors.deepPurpleAccent,
                      value: _radius,
                      min: 100,
                      max: 2000,
                      divisions: 19,
                      label: '${_radius.toInt()} m',
                      onChanged: (value) => setState(() => _radius = value),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
