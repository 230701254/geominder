// lib/services/live_location_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LiveLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Updates the user's current location in a specific document
  Future<void> updateUserLocation(Position position) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Don't do anything if not logged in

    // We use the user's ID as the document ID for simplicity
    await _firestore.collection('live_locations').doc(user.uid).set({
      'location': GeoPoint(position.latitude, position.longitude),
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  }
}