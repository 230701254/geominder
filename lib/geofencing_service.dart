import 'package:flutter/material.dart';
import 'package:geominder/models/reminder_model.dart';
import 'package:geominder/notification_service.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:permission_handler/permission_handler.dart';

class GeofencingService {
  // --- Singleton Setup ---
  factory GeofencingService() => _instance;
  GeofencingService._internal();
  static final GeofencingService _instance = GeofencingService._internal();

  final _geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: true,
    allowMockLocations: false,
    printDevLog: true,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC,
  );

  // --- GETTER ---
  bool get isServiceRunning => _geofenceService.isRunningService;

  // --- PUBLIC METHODS ---
  void initializeAndStart() {
    _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService.addActivityChangeListener(_onActivityChanged as ActivityChanged);
    _geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
    _geofenceService.start().catchError((error) {
      debugPrint('Error starting geofence service: $error');
    });
    debugPrint('Geofencing Service started.');
  }

  Future<void> updateGeofences(List<ReminderModel> reminders) async {
    final activeReminders = reminders.where((r) => r.isActive && r.id != null).toList();

    final allCurrentIds = _geofenceList.map((g) => g.id).toList();
    if (allCurrentIds.isNotEmpty) {
      await _removeGeofences(allCurrentIds);
    }

    for (final reminder in activeReminders) {
      await _addGeofence(reminder);
    }

    debugPrint('Geofences updated. Total active: ${_geofenceList.length}');
  }

  void stop() {
    _geofenceService.stop();
    debugPrint('Geofencing Service stopped.');
  }

  // --- PRIVATE HELPERS AND LISTENERS ---
  final List<Geofence> _geofenceList = [];
  final Map<String, ReminderModel> _reminderMap = {};

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    debugPrint('GEOFENCE STATUS CHANGED: ${geofence.id} - ${geofenceStatus.toString()}');
    if (geofenceStatus == GeofenceStatus.ENTER) {
      final reminder = _reminderMap[geofence.id];
      if (reminder != null) {
        await NotificationService().showReminderNotification(reminder);
      }
    }
  }

  // ✅ Fixed: positional params
 void _onActivityChanged(Activity activity, int confidence) {
  debugPrint('Activity changed: ${activity.type} with confidence $confidence');
}



  void _onLocationServicesStatusChanged(bool status) {
    debugPrint('Location services status changed: $status');
  }

  Future<void> _addGeofence(ReminderModel reminder) async {
    if (reminder.id == null) return;

    final geofence = Geofence(
      id: reminder.id!,
      latitude: reminder.latitude,
      longitude: reminder.longitude,
      radius: [
        GeofenceRadius(id: 'radius_${reminder.radius.round()}', length: reminder.radius),
      ],
    );

    _geofenceService.addGeofenceList([geofence]);
    _geofenceList.add(geofence);
    _reminderMap[reminder.id!] = reminder;
  }

  Future<void> _removeGeofences(List<String> reminderIds) async {
    if (reminderIds.isEmpty) return;

    final geofencesToRemove = _geofenceList
        .where((g) => reminderIds.contains(g.id))
        .toList();

    if (geofencesToRemove.isEmpty) return;

    _geofenceService.removeGeofenceList(geofencesToRemove);
    _geofenceList.removeWhere((g) => reminderIds.contains(g.id));

    for (final id in reminderIds) {
      _reminderMap.remove(id);
    }
  }

  // Add this method inside your GeofencingService class

Future<bool> requestPermissions() async {
  // Request location when the app is in use.
  var status = await Permission.locationWhenInUse.request();
  
  if (status.isGranted) {
    // If the user grants it, then request permission for background location access.
    var backgroundStatus = await Permission.locationAlways.request();
    if (backgroundStatus.isGranted) {
      return true;
    }
  }
  
  // If either permission is denied, the feature can't work.
  return false;
}
}
