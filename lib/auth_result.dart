import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class AuthResult {
  factory AuthResult.success({required String userId, required String email}) {
    return AuthResult._(success: true, userId: userId, email: email);
  }

  const AuthResult._({
    required this.success,
    this.userId,
    this.email,
    this.errorMessage,
  });

  factory AuthResult.error({required String message}) {
    return AuthResult._(success: false, errorMessage: message);
  }

  final String? userId;

  final bool success;

  final String? email;

  final String? errorMessage;
}
