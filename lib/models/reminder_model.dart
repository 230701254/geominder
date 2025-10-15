import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class ReminderModel {
  const ReminderModel({
    this.id, // This is the unique ID from MongoDB (_id), now optional.
    required this.userId, // This is the required Firebase User ID.
    required this.title,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isActive = true,
    this.createdAt,
  });

  /// The unique ID for the document in the MongoDB collection (e.g., _id).
  /// It's nullable because you won't have it when creating a new reminder locally.
  final String? id;

  /// The ID of the Firebase user who owns this reminder.
  final String userId;

  final String title;
  final String locationName;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  final DateTime? createdAt;

  /// Creates a ReminderModel instance from a JSON map.
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
  return ReminderModel(
    id: json['_id'] is Map
        ? json['_id']['\$oid'] as String
        : json['_id']?.toString(), // ✅ handles both types
    userId: json['userId'] as String,
    title: json['title'] as String,
    locationName: json['locationName'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    radius: (json['radius'] as num? ?? 100.0).toDouble(),
    isActive: json['isActive'] as bool? ?? true,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );
}


  /// Converts the ReminderModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      // We don't include 'id' here because the database generates it.
      'userId': userId,
      'title': title,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this ReminderModel but with the given fields replaced.
  ReminderModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? locationName,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}