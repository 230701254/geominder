// lib/screens/map_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // IMPORTANT: Replace with your actual Geoapify API key
  final String _apiKey = 'f4be9016fe6548249e2ef2471cc60b04';

  // Controllers and state variables
  final MapController _mapController = MapController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // State
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

  void _getCurrentLocation() async {
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
  }

  void _searchPlaces(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (query.length < 3) return;

      setState(() => _isLoading = true);

      final url = Uri.parse('https://api.geoapify.com/v1/geocode/search?text=$query&apiKey=$_apiKey');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          setState(() {
            _searchResults = json.decode(response.body)['features'];
          });
        }
      } catch (e) {
        // Handle error
        print(e);
      } finally {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Alarm Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _selectedLocation == null || _nameController.text.isEmpty
                ? null
                : () {
                    final newAlarm = AlarmModel(
                      id: const Uuid().v4(),
                      name: _nameController.text,
                      latitude: _selectedLocation!.latitude,
                      longitude: _selectedLocation!.longitude,
                      radius: _radius,
                    );
                    Navigator.of(context).pop(newAlarm);
                  },
          )
        ],
      ),
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? const LatLng(13.0827, 80.2707),
              initialZoom: 12,
              onTap: (_, location) {
                setState(() {
                  _selectedLocation = location;
                  _searchResults = []; // Clear search results on tap
                });
              },
            ),
            children: [
              // Map Tiles from Geoapify
              TileLayer(
                urlTemplate: 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$_apiKey',
                additionalOptions: {'apiKey': _apiKey},
              ),
              // Radius Circle
              if (_selectedLocation != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _selectedLocation!,
                      radius: _radius,
                      useRadiusInMeter: true,
                      color: Colors.blue.withOpacity(0.2),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              // Selected Location Marker
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          // Search UI on top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _searchPlaces,
                  decoration: InputDecoration(
                    labelText: 'Search for a place...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isLoading ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()) : null,
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final properties = _searchResults[index]['properties'];
                        return Card(
                          child: ListTile(
                            title: Text(properties['formatted']),
                            onTap: () {
                              final lon = properties['lon'];
                              final lat = properties['lat'];
                              setState(() {
                                _selectedLocation = LatLng(lat, lon);
                                _mapController.move(_selectedLocation!, 15.0);
                                _searchController.clear();
                                _searchResults = [];
                                FocusScope.of(context).unfocus(); // Close keyboard
                              });
                            },
                          ),
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Alarm Name', border: OutlineInputBorder()),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Text('Radius: ${_radius.toInt()} meters'),
                  Slider(
                    value: _radius,
                    min: 100.0,
                    max: 2000.0,
                    onChanged: (double value) => setState(() => _radius = value),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}