// lib/models/alarm_model.dart

class AlarmModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  bool isActive;

  AlarmModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isActive = true,
  });

  // --- NEW: Convert AlarmModel object to a Map (JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isActive': isActive,
    };
  }

  // --- NEW: Create AlarmModel object from a Map (JSON) ---
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      isActive: json['isActive'],
    );
  }
}