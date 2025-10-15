import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:geominder/globals/app_state.dart';
import 'package:geominder/auth_result.dart';
import 'package:provider/provider.dart';

@NowaGenerated()
class AuthScreen extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

@NowaGenerated()
class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  // **REMOVED**: The local _isLoading is redundant. AppState will manage all loading states.
  // bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // **REMOVED**: setState for isLoading is no longer needed.

    final appState = AppState.of(context, listen: false);
    AuthResult result;
    if (_isLogin) {
      result = await appState.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      result = await appState.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
    
    // The rest of this function can remain, as AppState already handles the error message display.
  }

  // **REPLACED**: This function now correctly calls AppState and uses try-catch.
  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final appState = AppState.of(context, listen: false);

    try {
      await appState.resetPassword(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // AppState sets the error message, which is displayed by the Consumer widget.
      // We can show a snackbar here as well for immediate feedback.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appState.errorMessage ?? 'Failed to send reset email.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) => Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'GeoMinder',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location-based reminders made simple',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (appState.errorMessage != null) ...[
                    // This error display is driven by AppState, which is good.
                    // ... (error container code remains the same)
                  ],
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    // **UPDATED**: Only uses appState.isLoading
                    enabled: !appState.isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    // **UPDATED**: Only uses appState.isLoading
                    enabled: !appState.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (!_isLogin && value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    // **UPDATED**: Only uses appState.isLoading
                    onPressed: appState.isLoading ? null : _authenticate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // **UPDATED**: Only uses appState.isLoading
                    child: appState.isLoading
                        ? const Row( /* ... (loading indicator remains the same) */ )
                        : Text(
                            _isLogin ? 'Sign In' : 'Sign Up',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    // **UPDATED**: Only uses appState.isLoading
                    onPressed: appState.isLoading
                        ? null
                        : () {
                            setState(() => _isLogin = !_isLogin);
                            appState.clearError();
                          },
                    child: Text(
                      _isLogin
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Sign In',
                    ),
                  ),
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      // **UPDATED**: Only uses appState.isLoading
                      onPressed: appState.isLoading ? null : _resetPassword,
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}