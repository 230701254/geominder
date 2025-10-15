import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geominder/globals/themes.dart';

// Import services from the correct 'services' directory
import 'package:geominder/models/reminder_model.dart';
import 'package:geominder/firebase_auth_service.dart';
import 'package:geominder/mongo_d_b_service.dart';
import 'package:geominder/geofencing_service.dart';
import 'package:geominder/notification_service.dart';
import 'package:geominder/auth_result.dart';
class AppState extends ChangeNotifier {
  AppState() {
    _authService.authStateChanges.listen((user) {
      _isAuthenticated = user != null;
      if (_isAuthenticated) {
        initializeApp();
      } else {
        _clearState();
      }
      notifyListeners();
    });
  }

  factory AppState.of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppState>(context, listen: listen);
  }

  // --- PRIVATE STATE ---
  ThemeData _theme = lightTheme;
  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _servicesInitialized = false;
  bool _isAuthenticated = false;

  // --- SERVICES ---
  final FirebaseAuthService _authService = FirebaseAuthService();
  final MongoDBService _mongoService = MongoDBService();
  final GeofencingService _geofencingService = GeofencingService();
  final NotificationService _notificationService = NotificationService();

  // --- GETTERS ---
  ThemeData get theme => _theme;
  Stream<User?> get authStateChanges => _authService.authStateChanges;
  List<ReminderModel> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userId => _authService.currentUserId;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _authService.currentUser?.email;
  bool get isApiConnected => _errorMessage == null;
  bool get isLocationServiceEnabled => _servicesInitialized;
  bool get isGeofencingActive => _geofencingService.isServiceRunning;

  // --- CORE APP METHODS ---

  Future<void> initializeApp() async {
    if (!isAuthenticated) return;
    _setLoading(true);
    _setError(null);
    await _loadUserReminders();
    await _initializeLocationServices();
    _setLoading(false);
  }

  Future<void> _initializeLocationServices() async {
    if (_servicesInitialized) return;
    try {
      final permissionGranted = await _geofencingService.requestPermissions();
      if (permissionGranted) {
        _geofencingService.initializeAndStart();
        await _notificationService.initialize();
        await _notificationService.requestPermission();
        _servicesInitialized = true;
        notifyListeners();
      } else {
        throw Exception('Required location permissions were not granted.');
      }
    } catch (e) {
      _setError('Error initializing location services: ${e.toString()}');
    }
  }

  void changeTheme(ThemeData newTheme) {
    if (_theme == newTheme) return;
    _theme = newTheme;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  // --- AUTH METHODS ---

  Future<AuthResult> signUp({required String email, required String password}) async {
    return _handleAuth(_authService.signUp(email: email, password: password));
  }

  Future<AuthResult> signIn({required String email, required String password}) async {
    return _handleAuth(_authService.signIn(email: email, password: password));
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.resetPassword(email: email);
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'An unknown error occurred.');
      rethrow;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // --- REMINDER METHODS ---

  Future<void> _loadUserReminders() async {
    if (userId == null) return;
    try {
      _reminders = await _mongoService.getUserReminders(userId!);
      await _geofencingService.updateGeofences(_reminders);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load reminders: ${e.toString()}');
    }
  }

  Future<void> refreshReminders() async {
    _setLoading(true);
    _setError(null);
    await _loadUserReminders();
    _setLoading(false);
  }

  Future<bool> addReminder(ReminderModel reminder) async {
    _setLoading(true);
    final newReminder = await _mongoService.createReminder(reminder);
    if (newReminder != null) {
      await refreshReminders();
      _setLoading(false);
      return true;
    } else {
      _setError('Failed to create reminder on the server.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> removeReminder(String reminderId) async {
    _setLoading(true);
    final success = await _mongoService.deleteReminder(reminderId);
    if (success) {
      await refreshReminders();
    } else {
      _setError('Failed to delete reminder on the server.');
    }
    _setLoading(false);
    return success;
  }

  Future<bool> updateReminder(ReminderModel updatedReminder) async {
    _setLoading(true);
    final returnedReminder = await _mongoService.updateReminder(updatedReminder);
    if (returnedReminder != null) {
      await refreshReminders();
      _setLoading(false);
      return true;
    } else {
      _setError('Failed to update reminder on the server.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> toggleReminderActive(ReminderModel reminder) async {
    final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);
    return await updateReminder(updatedReminder);
  }

  // --- PRIVATE HELPERS ---

  @override
  void dispose() {
    _geofencingService.stop();
    super.dispose();
  }
  
  Future<AuthResult> _handleAuth(Future<AuthResult> authFuture) async {
    _setLoading(true);
    _setError(null);
    final result = await authFuture;
    if (!result.success) {
      _setError(result.errorMessage);
    }
    _setLoading(false);
    return result;
  }

  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearState() {
    _reminders = [];
    _servicesInitialized = false;
    _geofencingService.stop();
  }
}