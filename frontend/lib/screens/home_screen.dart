// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/alarm_model.dart';
import 'map_screen.dart';
import 'settings_screen.dart'; // Import the new settings screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AlarmModel> _alarms = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    FlutterBackgroundService().startService();
    _loadAlarms();
  }

  Future<void> _requestPermissions() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsString = prefs.getString('alarms');
    if (alarmsString != null) {
      final List<dynamic> alarmsJson = json.decode(alarmsString);
      setState(() {
        _alarms = alarmsJson.map((json) => AlarmModel.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String alarmsString = json.encode(_alarms.map((alarm) => alarm.toJson()).toList());
    await prefs.setString('alarms', alarmsString);
  }

  // --- NEW: Function to delete an alarm ---
  void _deleteAlarm(String id) {
    setState(() {
      _alarms.removeWhere((alarm) => alarm.id == id);
    });
    _saveAlarms();
  }

  void _navigateAndAddAlarm(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );

    if (result != null && result is AlarmModel) {
      setState(() {
        _alarms.add(result);
      });
      _saveAlarms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoMinder Alarms'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        // --- NEW: Settings button ---
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _alarms.isEmpty
          ? const Center(
              child: Text(
                'No alarms set.\nPress the + button to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                // --- NEW: Wrap ListTile with Dismissible for swipe-to-delete ---
                return Dismissible(
                  key: Key(alarm.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteAlarm(alarm.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${alarm.name} deleted')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.pin_drop,
                      color: alarm.isActive ? Colors.blue : Colors.grey,
                    ),
                    title: Text(alarm.name),
                    subtitle: Text('${alarm.radius.toInt()}m radius'),
                    trailing: Switch(
                      value: alarm.isActive,
                      onChanged: (value) {
                        setState(() {
                          alarm.isActive = value;
                        });
                        _saveAlarms();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateAndAddAlarm(context);
        },
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}