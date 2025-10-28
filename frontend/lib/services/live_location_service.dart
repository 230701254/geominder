// lib/services/live_location_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'notification_service.dart';
import 'hill_climb_backend.dart';

class LiveLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Updates the user's current location in a specific document
  Future<void> updateUserLocation(Position position) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('live_locations').doc(user.uid).set({
      'location': GeoPoint(position.latitude, position.longitude),
      'lastUpdate': FieldValue.serverTimestamp(),
    });

    // Simulate a target location for demo (you can replace this)
    double targetLat = position.latitude + 0.001;
    double targetLng = position.longitude + 0.001;

    // Calculate distance
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetLat,
      targetLng,
    );

    // AI Hill Climbing trigger
    bool shouldTrigger = await checkHillClimbTrigger(distance);
    if (shouldTrigger) {
      NotificationService.showInstantNotification(
        title: 'AI Triggered 🎯',
        body: 'Hill Climbing optimized your location match!',
      );
    }
  }
}
