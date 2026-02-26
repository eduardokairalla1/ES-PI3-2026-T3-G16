/// --- Project entry point ---

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app.dart';


/// --- CODE ---

/// I am the application entry point.
Future<void> main() async {

  // ensure Flutter engine is initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // start root widget
  runApp(const MesclaInvestApp());
}
