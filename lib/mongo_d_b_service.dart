import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geominder/models/reminder_model.dart'; // Ensure this path is correct
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class MongoDBService {
  // --- Singleton Setup ---
  factory MongoDBService() => _instance;
  MongoDBService._internal();
  static final MongoDBService _instance = MongoDBService._internal();

  // --- Base URL ---
  // Use a conditional check for the platform to select the correct localhost address.
  // The corrected code
static final String _baseUrl = 'https://77620780a960.ngrok-free.app'; // Make sure this is still your computer's correct IP

  // Your ReminderModel MUST have fromJson() and toJson() methods.

  /// Fetches all reminders for a specific user from the API.
  Future<List<ReminderModel>> getUserReminders(String userId) async {
    try {
      final url = Uri.parse('$_baseUrl/reminders/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> remindersJson = json.decode(response.body);
        return remindersJson.map((json) => ReminderModel.fromJson(json)).toList();
      } else {
        debugPrint('Failed to fetch reminders. Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching reminders: $e');
      return [];
    }
  }

  /// Creates a new reminder by sending it to the API.
  Future<bool> createReminder(ReminderModel reminder) async {
    try {
      final url = Uri.parse('$_baseUrl/reminders');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reminder.toJson()),
      );

      return response.statusCode == 201; // 201 means "Created"
    } catch (e) {
      debugPrint('Error creating reminder: $e');
      return false;
    }
  }

  /// Updates an existing reminder via the API.
  Future<bool> updateReminder(ReminderModel reminder) async {
    // A reminder must have an ID to be updated.
    if (reminder.id == null) {
      debugPrint("Error: Reminder ID is null, cannot update.");
      return false;
    }
    try {
      final url = Uri.parse('$_baseUrl/reminders/${reminder.id}');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reminder.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating reminder: $e');
      return false;
    }
  }

  /// Deletes a reminder by its ID via the API.
  Future<bool> deleteReminder(String reminderId) async {
    try {
      final url = Uri.parse('$_baseUrl/reminders/$reminderId');
      final response = await http.delete(url);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      return false;
    }
  }
}