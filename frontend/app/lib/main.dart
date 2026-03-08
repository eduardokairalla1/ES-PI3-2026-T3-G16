/// --- Project entry point ---

// --- IMPORTS ---
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app.dart';
import 'package:mesclainvest/firebase_options.dart';


/// --- CODE ---

/// I am the application entry point.
Future<void> main() async {

  // ensure Flutter engine is initialized before async calls
  WidgetsFlutterBinding.ensureInitialized();

  // load environment variables
  await dotenv.load(fileName: '.env');

  // read emulator configuration
  final useEmulator = dotenv.env['USE_EMULATOR'] == 'true';
  final emulatorHost = dotenv.env['EMULATOR_HOST'] ?? 'localhost';
  final authEmulatorPort =
    int.tryParse(dotenv.env['AUTH_EMULATOR_PORT'] ?? '9099') ?? 9099;

  // initialize firebase client
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // emulator config is enabled: configure firebase auth to use it
  if (useEmulator == true) {
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, authEmulatorPort);
  }

  // start root widget
  runApp(const MesclaInvestApp());
}
