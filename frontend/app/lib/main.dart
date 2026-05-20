// --- Project entry point ---

// --- IMPORTS ---
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mesclainvest/app/app.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/app/theme/theme_controller.dart';
import 'package:mesclainvest/core/services/auth.dart';
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
  final firestoreEmulatorPort =
    int.tryParse(dotenv.env['FIRESTORE_EMULATOR_PORT'] ?? '8080') ?? 8080;

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
      FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, firestoreEmulatorPort);
      FirebaseFunctions.instance.useFunctionsEmulator(emulatorHost, functionsEmulatorPort);
      await FirebaseStorage.instance.useStorageEmulator(emulatorHost, storageEmulatorPort);
    }
  }

  // load persisted theme preference before first frame
  await ThemeController.instance.load();

  // Firebase Auth restores the session asynchronously on web, which means
  // `currentUser` can be null at this exact moment even when a valid session
  // is being restored from IndexedDB. Wait for the first emission of
  // `authStateChanges` so we know the real state before deciding whether to
  // pre-fetch the profile. This avoids the "Usuário" / "—" flash on refresh.
  final authService = AuthService();
  final restoredUser = await authService.authStateChanges.first;
  if (restoredUser != null) {
    try {
      await AppState.instance.loadProfile(authService);
    } catch (_) {
      // best-effort; pages render with placeholders and the listener below
      // will retry on the next auth state change
    }
  }

  // Keep AppState in sync with future auth state changes so sign-out from
  // anywhere in the app clears the profile, and sign-in (e.g. from a fresh
  // tab) repopulates it without needing an explicit call site.
  authService.authStateChanges.listen((user) async {
    if (user == null) {
      AppState.instance.clearProfile();
    } else if (AppState.instance.profile == null) {
      try {
        await AppState.instance.loadProfile(authService);
      } catch (_) {}
    }
  });

  // start root widget
  runApp(const MesclaInvestApp());
}
