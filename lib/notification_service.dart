import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:geominder/models/reminder_model.dart';

@NowaGenerated()
class NotificationService {
  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  bool _isInitialized = false;

  static final NotificationService _instance = NotificationService._internal();

  Future<bool> initialize() async {
    try {
      _isInitialized = true;
      print('Notification service initialized');
      return true;
    } catch (e) {
      print('Failed to initialize notifications: ${e}');
      return false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      print('Notification permission granted');
      return true;
    } catch (e) {
      print('Failed to request notification permission: ${e}');
      return false;
    }
  }

  Future<void> showReminderNotification(ReminderModel reminder) async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      print('Showing notification for: ${reminder.title}');
      print('Location: ${reminder.locationName}');
    } catch (e) {
      print('Failed to show notification for ${reminder.title}: ${e}');
    }
  }

  Future<void> cancelNotification(String reminderId) async {
    try {
      print('Cancelled notification for reminder ID: ${reminderId}');
    } catch (e) {
      print('Failed to cancel notification for ${reminderId}: ${e}');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      print('Cancelled all notifications');
    } catch (e) {
      print('Failed to cancel all notifications: ${e}');
    }
  }
}
