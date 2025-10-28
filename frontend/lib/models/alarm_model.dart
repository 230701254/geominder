// lib/models/alarm_model.dart

class AlarmModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  bool isActive;
  List<String> sharedWith; // 👈 list of Gmail IDs this alarm is shared with
  String? sharedBy; // 👈 optional field for showing who shared it

  AlarmModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isActive = true,
    this.sharedWith = const [],
    this.sharedBy,
  });

  // --- Convert AlarmModel object to JSON ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isActive': isActive,
      'sharedWith': sharedWith,
      'sharedBy': sharedBy,
    };
  }

  // --- Create AlarmModel object from JSON ---
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      name: json['name'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      isActive: json['isActive'] ?? true,
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      sharedBy: json['sharedBy'], // 👈 this handles alarms shared *to* the user
    );
  }
}
