// Eduardo Kairalla - 24024241

// --- Auth service ---

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';
import 'package:mesclainvest/core/models/user_profile.dart';

// --- CODE ---

/// I handle Firebase Authentication operations.
class AuthService {
  // attributes
  final _auth = FirebaseAuth.instance;

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
  /// :returns: true if 2FA verification is required, false otherwise
  Future<bool> signIn(String email, String password) async {

    // sign in with Firebase Authentication
    try {
      await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
    }
    on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(
        e.code,
        originalError: e,
        stackTrace: StackTrace.current,
      ) ?? InfrastructureException(
        originalError: e,
        stackTrace: StackTrace.current,
      );
    }
    catch (e) {
      throw InfrastructureException(
        message:      e.toString(),
        originalError: e,
        stackTrace:    StackTrace.current,
      );
    }

    // fetch profile to check 2FA status
    final profile = await getProfile();

    if (profile.twoFaEnabled) {
      AppState.instance.setPendingTwoFa();
      return true;
    }

    AppState.instance.setProfile(profile);
    return false;
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
    // register with Firebase Authentication
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
    // so the account doesn't end up in a broken state
    try {
      await FirebaseFunctions.instance.httpsCallable('onUserCreated').call({
        'fullName': fullName,
        'cpf': cpf,
        'phone': phone,
        'birthDate': birthDate,
      });
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

    // sign out so the user lands on /login and authenticates explicitly
    await _auth.signOut();
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
      final resetUrl = kIsWeb
          ? Uri.base.resolve('/reset-password').toString()
          : 'https://mesclainvest-eda16.firebaseapp.com/reset-password';
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: resetUrl,
          handleCodeInApp: true,
        ),
      );
    }
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

  /// I confirm a password reset using the oob code from the reset email.
  ///
  /// :param oobCode: the one-time code from the reset link
  /// :param newPassword: the new password to set
  ///
  /// :throws AuthException: if the code is expired or invalid
  /// :throws InfrastructureException: if any other error occurs
  ///
  /// :returns: void
  Future<void> confirmPasswordReset(String oobCode, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(
        code:        oobCode,
        newPassword: newPassword,
      );
    }
    on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(
        e.code,
        originalError: e,
        stackTrace:    StackTrace.current,
      ) ?? InfrastructureException(
        originalError: e,
        stackTrace:    StackTrace.current,
      );
    }
    catch (e) {
      throw InfrastructureException(
        message:      e.toString(),
        originalError: e,
        stackTrace:    StackTrace.current,
      );
    }
  }


  /// I sign out the current user.
  ///
  /// :throws InfrastructureException: if sign-out fails
  ///
  /// :returns: void
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw InfrastructureException(
        message:      e.toString(),
        originalError: e,
        stackTrace:    StackTrace.current,
      );
    }
  }
}
