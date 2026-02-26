// --- Home page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


// --- CODE ---

/// I represent the home page.
class HomePage extends StatelessWidget {

  // constructor
  const HomePage({super.key});


  /// I build the home page widget tree.
  /// 
  /// :param context: the build context
  /// 
  /// :returns: the home page widget tree
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // app title
            const Text('MesclaInvest'),
            const SizedBox(height: 24),

            // login button
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login'),
            ),
            const SizedBox(height: 8),

            // register button
            ElevatedButton(
              onPressed: () => context.go('/register'),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
