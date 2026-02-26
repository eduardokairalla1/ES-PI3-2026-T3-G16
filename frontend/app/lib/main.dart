/// --- Project entry point ---

// --- IMPORTS ---
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app.dart';
import 'package:mesclainvest/firebase_options.dart';


/// --- CODE ---

/// I am the application entry point.
Future<void> main() async {

  // ensure Flutter engine is initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // initialize firebase client
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // start root widget
  runApp(const MesclaInvestApp());
}
