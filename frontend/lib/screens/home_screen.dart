import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alarm_model.dart';
import '../services/background_service.dart'; // ✅ for showNotification
import 'map_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AlarmModel> _alarms = [];
  Stream<QuerySnapshot>? _alarmStream;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    FlutterBackgroundService().startService();
    _initAlarmStream();
  }

  Future<void> _requestPermissions() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _initAlarmStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final alarmsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('alarms');

    _alarmStream = alarmsCollection.snapshots();

    _alarmStream!.listen((snapshot) {
      setState(() {
        _alarms = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return AlarmModel.fromJson(data);
        }).toList();
      });
    });
  }

  Future<void> _addAlarm(AlarmModel alarm) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final alarmsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('alarms');

    await alarmsCollection.doc(alarm.id).set(alarm.toJson());
  }

  Future<void> _deleteAlarm(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final alarmsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('alarms');

    await alarmsCollection.doc(id).delete();
  }

  Future<void> _updateAlarm(AlarmModel alarm) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final alarmsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('alarms');

    await alarmsCollection.doc(alarm.id).update(alarm.toJson());
  }

  /// 🚀 Navigate to Map and add Alarm
  void _navigateAndAddAlarm(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );

    if (result != null && result is AlarmModel) {
      await _addAlarm(result);

      try {
        // 🧭 Get current location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // 📏 Calculate distance
        double dist = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          result.latitude,
          result.longitude,
        );

        debugPrint("📍 Current distance from alarm: ${dist.toStringAsFixed(2)} m");

        // 🔥 If within alarm radius → instant notification
        if (dist <= result.radius) {
          showNotification("🚨 Alarm '${result.name}' triggered instantly!");
          debugPrint("🔥 Immediate notification fired!");
        } else {
          debugPrint("✅ Alarm saved. You’re ${dist.toStringAsFixed(1)}m away.");
        }
      } catch (e) {
        debugPrint("❌ Error checking location: $e");
      }
    }
  }

  /// 🧑‍🤝‍🧑 Share alarm with another user (by Gmail)
  Future<void> _shareAlarm(AlarmModel alarm) async {
    final TextEditingController emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Share Alarm"),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: "Friend’s Gmail",
              hintText: "example@gmail.com",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) return;

                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                // Find friend by email
                final friendQuery = await FirebaseFirestore.instance
                    .collection('users')
                    .where('email', isEqualTo: email)
                    .get();

                if (friendQuery.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not found 😢")),
                  );
                  return;
                }

                final friendDoc = friendQuery.docs.first.reference;

                // Update your own alarm data (add sharedWith)
                final updatedAlarm = {
                  ...alarm.toJson(),
                  'sharedWith': FieldValue.arrayUnion([email]),
                };

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('alarms')
                    .doc(alarm.id)
                    .set(updatedAlarm, SetOptions(merge: true));

                // Create a copy in friend's alarms
                await friendDoc.collection('alarms').doc(alarm.id).set({
                  ...alarm.toJson(),
                  'sharedBy': user.email,
                  'shared': true,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Alarm shared with $email 🎉")),
                );

                Navigator.pop(context);
              },
              child: const Text("Share"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoMinder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _alarms.isEmpty
          ? Center(
              child: Text(
                'No alarms set.\nPress the + button to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return Dismissible(
                  key: Key(alarm.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _deleteAlarm(alarm.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${alarm.name} deleted')),
                    );
                  },
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 4,
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: colorScheme.primary.withOpacity(0.3),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: Icon(
                        Icons.location_on_rounded,
                        color: alarm.isActive ? colorScheme.primary : Colors.grey,
                        size: 30,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              alarm.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          if (alarm.sharedBy != null)
                            const Icon(Icons.link, size: 18, color: Colors.blueAccent),
                        ],
                      ),
                      subtitle: Text(
                        alarm.sharedBy != null
                            ? 'Shared by ${alarm.sharedBy}'
                            : '${alarm.radius.toInt()}m radius',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_rounded),
                            onPressed: () => _shareAlarm(alarm),
                          ),
                          Switch(
                            value: alarm.isActive,
                            activeColor: colorScheme.primary,
                            onChanged: (value) async {
                              setState(() {
                                alarm.isActive = value;
                              });
                              await _updateAlarm(alarm);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndAddAlarm(context),
        child: const Icon(Icons.add_location_alt_rounded, size: 28),
      ),
    );
  }
}
