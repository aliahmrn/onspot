import 'package:onspot_officer/service/auth_service.dart';

class AuthMiddleware {
  final AuthService _authService = AuthService();

  Future<bool> isAuthenticated() async {
    final token = await _authService.getToken();
    return token != null; // Return true if token exists, indicating the user is authenticated
  }
}
