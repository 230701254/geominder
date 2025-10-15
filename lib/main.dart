import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geominder/firebase_options.dart';

import 'package:geominder/globals/app_state.dart';
import 'package:geominder/pages/auth_screen.dart';
import 'package:geominder/pages/reminder_list_screen.dart';
import 'package:geominder/pages/add_reminder_screen.dart';
import 'package:geominder/pages/settings_screen.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

@NowaGenerated({'visibleInNowa': false})
class MyApp extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'GeoMinder',
            theme: appState.theme,
            home: const AuthWrapper(),
            routes: {
              'AuthScreen': (context) => const AuthScreen(),
              'ReminderListScreen': (context) => const ReminderListScreen(),
              'AddReminderScreen': (context) => const AddReminderScreen(),
              'SettingsScreen': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

/// This widget listens to the auth state and shows the correct screen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return StreamBuilder(
      stream: appState.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const ReminderListScreen();
        }
        return const AuthScreen();
      },
    );
  }
}