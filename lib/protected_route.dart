import 'package:flutter/material.dart';
import 'package:onspot_facility/service/auth_middleware.dart'; // Import only AuthMiddleware

class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthMiddleware().isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || !snapshot.data!) {
          // If not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login'); // Adjust route name as needed
          });
          return SizedBox.shrink();
        }
        return child; // User is authenticated, show the protected content
      },
    );
  }
}
