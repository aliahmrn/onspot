import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';

// Define AuthService provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
