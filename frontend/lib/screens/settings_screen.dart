// lib/screens/settings_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geominder/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // --- User Profile Section ---
          if (currentUser != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Logged In As'),
              subtitle: Text(currentUser.email ?? 'No email available'),
            ),
          const Divider(),

          // --- App Settings Section ---
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            value: false, // You would connect this to a theme provider
            onChanged: (bool value) {
              // Add logic here to change the app's theme
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme switching not implemented yet.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Sound'),
            subtitle: const Text('Default'),
            onTap: () {
              // Add navigation to a sound picker page
            },
          ),
          const Divider(),

          // --- About Section ---
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About GeoMinder'),
            onTap: () {
              // Add navigation to an about page
            },
          ),

          // --- Sign Out Button ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              authService.signOut();
              // Pop until the login screen is shown
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}