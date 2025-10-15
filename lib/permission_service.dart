import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestLocationPermissions(BuildContext context) async {
    // Step 1️⃣ Ask for foreground (While using the app)
    var foreground = await Permission.location.request();

    if (foreground.isGranted) {
      debugPrint("✅ Foreground location granted");

      // Step 2️⃣ After short delay, ask for background (shows 'Allow all the time')
      Future.delayed(const Duration(seconds: 1), () async {
        var background = await Permission.locationAlways.request();

        if (background.isGranted) {
          debugPrint("✅ Background location (All the time) granted");
        } else if (background.isDenied) {
          debugPrint("❌ Background access denied");
          _showManualSettingsDialog(context);
        } else if (background.isPermanentlyDenied) {
          debugPrint("⚠️ Permanently denied, opening settings");
          await openAppSettings();
        }
      });
    } else {
      debugPrint("❌ Foreground location denied");
    }
  }

  static void _showManualSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enable Background Location"),
        content: const Text(
          "To trigger reminders automatically, please allow ‘All the time’ location access in your device settings.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(ctx);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
