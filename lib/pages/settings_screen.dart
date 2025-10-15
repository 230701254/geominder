import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';
import 'package:geominder/globals/app_state.dart';
import 'package:geominder/models/reminder_model.dart'; // Keep this for the _showDeleteDialog if you keep it here

@NowaGenerated()
class SettingsScreen extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const SettingsScreen({super.key});

  // This helper widget is well-written and can stay as is.
  Widget _buildStatusRow(String label, bool isActive, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isActive ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.green[400] : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'Active' : 'Inactive',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use a Consumer here to get access to the AppState
    
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<AppState>(
        builder: (context, appState, child) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- ACCOUNT CARD ---
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text('Email: ${appState.userEmail ?? 'Not available'}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: appState.isLoading ? null : () => _showLogoutDialog(context, appState),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                        ),
                        
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            

            // --- SERVICES CARD ---
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('System Status', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    // All status information now comes directly from AppState
                    _buildStatusRow('Authentication', appState.isAuthenticated, Icons.security),
                    const SizedBox(height: 8),
                    _buildStatusRow('API Connection', appState.isApiConnected, Icons.cloud_sync),
                    const SizedBox(height: 8),
                    _buildStatusRow('Location Services', appState.isLocationServiceEnabled, Icons.location_on),
                    const SizedBox(height: 8),
                    _buildStatusRow('Background Monitoring', appState.isGeofencingActive, Icons.radar),
                    const SizedBox(height: 16),
                     SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: appState.isLoading ? null : () async {
                           await appState.refreshReminders(); // "Sync" is the same as "Refresh"
                           if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data refreshed from server'), backgroundColor: Colors.green),
                            );
                           }
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('Refresh Data'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 16),

            // --- ABOUT CARD ---
            Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('About GeoMinder', style: Theme.of(context).textTheme.titleLarge),
                     const SizedBox(height: 12),
                     Text('Version: 1.0.0 (MVP)', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGS ---
  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await appState.signOut();
              if (context.mounted) {
                // This will remove all screens and push the AuthScreen
                Navigator.of(context).pushNamedAndRemoveUntil('AuthScreen', (route) => false);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}