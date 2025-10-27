// lib/screens/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geominder/screens/home_screen.dart';
import 'package:geominder/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If user is not logged in, show login screen
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        // If user is logged in, show home screen
        return const HomeScreen();
      },
    );
  }
}