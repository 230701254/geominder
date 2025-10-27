// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:geominder/services/auth_service.dart';
import 'package:geominder/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _showSignup = false;

  void _toggleView() {
    setState(() {
      _showSignup = !_showSignup;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSignup) {
      return SignupScreen(onLoginTap: _toggleView);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome Back!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _authService.signInWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: _toggleView,
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}