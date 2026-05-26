// --- Auth service ---
//
// Eduardo Kairalla - 24024241
// Firebase Auth facade used by the UI and AppState.

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/models/user_profile.dart';

// --- CODE ---

/// I handle Firebase Authentication operations.
/// I am a singleton — access me via [AuthService.instance].
class AuthService {
  // singleton
  AuthService._();
  static final AuthService instance = AuthService._();

  // attributes
  final _auth = FirebaseAuth.instance;

  /// I am true while a new account registration is in progress.
  /// The auth-state listener in main.dart must skip loadProfile() when this is true
  /// to avoid a race condition where onGetProfile is called before onUserCreated
  /// has finished writing the user document to Firestore.
  bool isRegistering = false;

  /// I return the current authenticated user.
  ///
  /// :returns: the current user, or null if not authenticated
  User? get currentUser => _auth.currentUser;

  /// I return a stream of auth state changes.
  ///
  /// :returns: a stream of User? representing the authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// I sign in with email and password.
  ///
  /// :param email: the user's email
  /// :param password: the user's password
  ///
  /// :throws AuthException: if the sign-in fails
  /// :throws InfrastructureException: if any other error occurs
  ///
  /// :returns: void
  Future<void> signIn(String email, String password) async {
    // sign in with Firebase Authentication
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    }
    // error occurred in Firebase Authentication: trow a custom AuthException
    on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(
            e.code,
            originalError: e,
            stackTrace: StackTrace.current,
          ) ??
          InfrastructureException(
            originalError: e,
            stackTrace: StackTrace.current,
          );
    }
    // any other error: throw a InfrastructureException
    catch (e) {
      throw InfrastructureException(
        message: e.toString(),
        originalError: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// I register a new user with email and password.
  ///
  /// :param email: the user's email
  /// :param password: the user's password
  /// :param fullName: the user's full name
  /// :param cpf: the user's CPF
  /// :param phone: the user's phone number
  ///
  /// :throws AuthException: if the registration fails
  /// :throws InfrastructureException: if any other error occurs
  ///
  /// :returns: void
  Future<void> register(
    String email,
    String password,
    String fullName,
    String cpf,
    String phone,
    String birthDate,
  ) async {
    isRegistering = true;
    try {
      // register with Firebase Authentication
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user?.getIdToken(true);
      } on FirebaseAuthException catch (e) {
        throw AuthException.fromFirebaseCode(
              e.code,
              originalError: e,
              stackTrace: StackTrace.current,
            ) ??
            InfrastructureException(
              originalError: e,
              stackTrace: StackTrace.current,
            );
      }

      // persist user metadata — if this fails, delete the just-created auth user
      // so the account doesn't end up in a broken state.
      // The isRegistering flag tells the auth-state listener in main.dart to skip
      // the premature loadProfile() call that would race against this write.
      try {
        final callable = FirebaseFunctions.instance.httpsCallable(
          'onUserCreated',
        );
        final payload = {
          'fullName': fullName,
          'cpf': cpf,
          'phone': phone,
          'birthDate': birthDate,
        };

        try {
          await callable.call(payload);
        } on FirebaseFunctionsException catch (e) {
          if (e.code != 'unauthenticated') rethrow;
          await _auth.currentUser?.getIdToken(true);
          await callable.call(payload);
        }
      } on FirebaseFunctionsException catch (e) {
        try {
          await _auth.currentUser?.delete();
        } catch (_) {
          // avoid masking the original exception
        }
        await _auth.signOut();
        if (e.code == 'invalid-argument' &&
            (e.message?.contains('CPF') ?? false)) {
          throw AuthException.cpfAlreadyInUse(
            originalError: e,
            stackTrace: StackTrace.current,
          );
        }
        throw InfrastructureException(
          message: e.message ?? e.toString(),
          originalError: e,
          stackTrace: StackTrace.current,
        );
      } catch (e) {
        try {
          await _auth.currentUser?.delete();
        } catch (_) {
          // avoid masking the original exception
        }
        await _auth.signOut();
        throw InfrastructureException(
          message: e.toString(),
          originalError: e,
          stackTrace: StackTrace.current,
        );
      }
    } finally {
      isRegistering = false;
    }
  }

  /// I send a password reset email to the given address.
  ///
  /// :param email: the email address to send the reset link to
  ///
  /// :throws AuthException: if the email is invalid or not found
  /// :throws InfrastructureException: if any other error occurs
  ///
  /// :returns: void
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final resetUrl = Uri.base.resolve('/reset-password').toString();
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: resetUrl,
          handleCodeInApp: true,
        ),
      );
    }
    // error occurred in Firebase Authentication: throw a custom AuthException
    on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(
            e.code,
            originalError: e,
            stackTrace: StackTrace.current,
          ) ??
          InfrastructureException(
            originalError: e,
            stackTrace: StackTrace.current,
          );
    }
    // any other error: throw an InfrastructureException
    catch (e) {
      throw InfrastructureException(
        message: e.toString(),
        originalError: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// I fetch the authenticated user's profile from the backend.
  ///
  /// :throws InfrastructureException: if the call fails
  ///
  /// :returns: the user's [UserProfile]
  Future<UserProfile> getProfile() async {
    try {
      // call onGetProfile backend function
      final result = await FirebaseFunctions.instance
          .httpsCallable('onGetProfile')
          .call<Map<String, dynamic>>();

      // build and return a UserProfile from the result
      return UserProfile.fromMap(Map<String, dynamic>.from(result.data));
    } on FirebaseFunctionsException catch (e) {
      // If the profile is not found on the backend (orphaned account),
      // we delete the Auth user and sign out to avoid leaving them in a broken state.
      if (e.code == 'unauthenticated' &&
          (e.message?.contains('Profile not found') ?? false)) {
        try {
          await _auth.currentUser?.delete();
        } catch (_) {
          // ignore to avoid masking original exception
        }
        await _auth.signOut();
        throw AuthException.userNotFound(
          originalError: e,
          stackTrace: StackTrace.current,
        );
      }
      throw InfrastructureException(
        message: e.message ?? e.toString(),
        originalError: e,
        stackTrace: StackTrace.current,
      );
    } catch (e) {
      throw InfrastructureException(
        message: e.toString(),
        originalError: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// I sign out the current user.
  ///
  /// :returns: void
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
