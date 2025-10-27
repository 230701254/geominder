import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // Register all necessary plugins for background isolate
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final liveLocationService = LiveLocationService();

  // Run periodic task every 1 minute
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
    } catch (e) {
      // Couldn’t get location, just skip this cycle
      return;
    }

    // Update live location
    liveLocationService.updateUserLocation(position);
    service.invoke('updateLocation', {
      "latitude": position.latitude,
      "longitude": position.longitude,
    });

    // Check stored alarms
    final prefs = await SharedPreferences.getInstance();
    final alarmsString = prefs.getString('alarms');
    if (alarmsString == null) return;

    final alarms = (json.decode(alarmsString) as List)
        .map((i) => AlarmModel.fromJson(i))
        .toList();

    bool triggered = false;

    for (var alarm in alarms) {
      if (alarm.isActive) {
        final dist = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          alarm.latitude,
          alarm.longitude,
        );

        // Check if within range
        if (dist <= alarm.radius) {
          showNotification(alarm.name);
          alarm.isActive = false;
          triggered = true;
        }
      }
    }

    // Save updated alarms if any triggered
    if (triggered) {
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
    'Alarm: $alarmName',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        'GeoMinder Service',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher', // Safe default icon
      ),
    ),
  );
}
