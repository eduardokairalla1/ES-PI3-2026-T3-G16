/// --- Project entry point ---
library;

// --- IMPORTS ---
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app.dart';
import 'package:mesclainvest/firebase_options.dart';


/// --- CODE ---

// tracks whether Firebase has been configured in this process (survives hot restart)
bool _firebaseReady = false;

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
  final functionsEmulatorPort =
    int.tryParse(dotenv.env['FUNCTIONS_EMULATOR_PORT'] ?? '5001') ?? 5001;
  final storageEmulatorPort =
    int.tryParse(dotenv.env['STORAGE_EMULATOR_PORT'] ?? '9199') ?? 9199;

  if (!_firebaseReady) {
    _firebaseReady = true;

    // initialize Firebase — Android auto-initializes natively before Dart runs,
    // so duplicate-app is expected and can be ignored
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }

    // point all Firebase services at the local emulators
    if (useEmulator) {
      await FirebaseAuth.instance.useAuthEmulator(emulatorHost, authEmulatorPort);
      FirebaseFunctions.instance.useFunctionsEmulator(emulatorHost, functionsEmulatorPort);
      await FirebaseStorage.instance.useStorageEmulator(emulatorHost, storageEmulatorPort);
    }
  }

  // start root widget
  runApp(const MesclaInvestApp());
}
