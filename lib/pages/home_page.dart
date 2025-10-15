import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';
import 'package:geominder/globals/app_state.dart';

@NowaGenerated()
class HomePage extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (appState.isAuthenticated) {
            Navigator.of(context).pushReplacementNamed('ReminderListScreen');
          } else {
            Navigator.of(context).pushReplacementNamed('AuthScreen');
          }
        });
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.location_on, size: 64, color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'GeoMinder',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 32),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}
