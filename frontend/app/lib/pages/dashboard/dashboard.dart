// --- Dashboard page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesclainvest/core/services/auth.dart';


// --- CODE ---

/// I represent the dashboard page.
class DashboardPage extends StatelessWidget {

  // constructor
  const DashboardPage({super.key});


  /// I build the widget tree for the dashboard page.
  /// 
  /// :returns: the widget tree for this page
  @override
  Widget build(BuildContext context) {

    // get the auth service
    final authService = AuthService();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // welcome message
            const Text('Dashboard'),
            const SizedBox(height: 24),

            // logout button
            ElevatedButton(
              onPressed: () async {

                // sign out the user
                await authService.signOut();

                // widget is still mounted: navigate to the login page
                if (context.mounted) context.go('/login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
