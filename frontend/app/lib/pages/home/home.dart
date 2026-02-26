// --- Home page ---

// --- IMPORTS ---
import 'package:flutter/material.dart';


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
          ],
        ),
      ),
    );
  }
}
