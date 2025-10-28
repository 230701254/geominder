import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../firebase_options.dart';
import '../models/alarm_model.dart';
import 'live_location_service.dart';

/// Notification channel ID for GeoMinder
const notificationChannelId = 'geominder_channel';

/// Flutter local notifications plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Initializes the background service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Create Android notification channel for background service
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'GeoMinder Service',
    description: 'Used for location alarm notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Configure the background service
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'GeoMinder Service',
      initialNotificationContent: 'Monitoring your location for alarms.',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
    ),
  );
}

/// Background service entry point
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final liveLocationService = LiveLocationService();

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
    } catch (e) {
      return; // Skip this cycle if location fails
    }

    liveLocationService.updateUserLocation(position);
    service.invoke('updateLocation', {
      "latitude": position.latitude,
      "longitude": position.longitude,
    });

    // Load stored alarms
    final prefs = await SharedPreferences.getInstance();
    final alarmsString = prefs.getString('alarms');
    if (alarmsString == null) return;

    final alarms = (json.decode(alarmsString) as List)
        .map((i) => AlarmModel.fromJson(i))
        .toList();

    // --- Hill Climbing Optimization ---
    final activeAlarms =
        alarms.where((alarm) => alarm.isActive == true).toList();

    if (activeAlarms.isEmpty) return;

    AlarmModel? bestAlarm;
    double bestDistance = double.infinity;

    for (var alarm in activeAlarms) {
      final dist = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        alarm.latitude,
        alarm.longitude,
      );

      // 🧠 Optional AI Hill-Climb Trigger via Flask Backend
      try {
        final url = Uri.parse('http://192.168.1.2:5000/hillclimb'); // <-- change IP if needed
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'distance': dist,
            'radius': alarm.radius,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          bool shouldTrigger = data['trigger'] ?? false;

          if (shouldTrigger) {
            flutterLocalNotificationsPlugin.show(
              DateTime.now().millisecond,
              'AI Triggered 🎯',
              'Hill Climbing optimized your location match for ${alarm.name}!',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  notificationChannelId,
                  'GeoMinder Service',
                  importance: Importance.high,
                  priority: Priority.high,
                  playSound: true,
                  icon: '@mipmap/ic_launcher',
                ),
              ),
            );
          }
        }
      } catch (e) {
        print('AI trigger error: $e');
      }

      // Local optimization (normal Hill Climb)
      if (dist < bestDistance) {
        bestDistance = dist;
        bestAlarm = alarm;
      }
    }

    // Trigger if best alarm is within radius
    if (bestAlarm != null && bestDistance <= bestAlarm.radius) {
      showNotification(bestAlarm.name);
      bestAlarm.isActive = false;

      // Update stored alarms
      await prefs.setString(
        'alarms',
        json.encode(alarms.map((a) => a.toJson()).toList()),
      );
    }
  });
}

/// Show notification when alarm is triggered
void showNotification(String alarmName) {
  flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecond,
    'Approaching Destination!',
    'Alarm: $alarmName (Optimized by AI)',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        'GeoMinder Service',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}
