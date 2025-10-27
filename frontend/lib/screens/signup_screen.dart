// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:geominder/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onLoginTap;
  const SignupScreen({super.key, required this.onLoginTap});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create Account', style: Theme.of(context).textTheme.headlineMedium),
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
                _authService.signUpWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );
              },
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: widget.onLoginTap,
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}