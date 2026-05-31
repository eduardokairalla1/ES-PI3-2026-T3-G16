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


  /// I verify a TOTP code during login.
  /// On success, loads the profile into AppState and clears the pending 2FA state.
  ///
  /// :param code: 6-digit TOTP code from the authenticator app
  ///
  /// :throws AuthException: if the code is invalid
  /// :throws InfrastructureException: if any other error occurs
  ///
  /// :returns: void
  Future<void> verify2FA(String code) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('onVerify2FA')
          .call({'code': code});
    }
    on FirebaseFunctionsException catch (e) {
      if (e.code == 'invalid-argument') {
        throw AuthException.invalidTwoFACode(
          originalError: e,
          stackTrace:    StackTrace.current,
        );
      }
      throw InfrastructureException(
        message:      e.message ?? e.toString(),
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

    // verified: load profile and clear pending state
    final profile = await getProfile();
    AppState.instance.setProfile(profile);
    AppState.instance.clearPendingTwoFa();
  }


  /// I start the 2FA setup process — generates a TOTP secret on the backend
  /// and returns the otpauth URI to display as a QR code.
  ///
  /// :throws InfrastructureException: if any error occurs
  ///
  /// :returns: the otpauth:// URI string
  Future<String> setup2FA() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('onSetup2FA')
          .call<Map<String, dynamic>>();
      return (result.data as Map)['otpauthUri'] as String;
    }
    catch (e) {
      throw InfrastructureException(
        message:      e.toString(),
        originalError: e,
        stackTrace:    StackTrace.current,
      );
    }
  }


  /// I confirm the 2FA setup by verifying the first code from the authenticator app.
  ///
  /// :param code: 6-digit TOTP code
  ///
  /// :throws AuthException: if the code is invalid
  /// :throws InfrastructureException: if any other error occurs
  ///
  /// :returns: void
  Future<void> confirmSetup2FA(String code) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('onConfirmSetup2FA')
          .call({'code': code});
    }
    on FirebaseFunctionsException catch (e) {
      if (e.code == 'invalid-argument') {
        throw AuthException.invalidTwoFACode(
          originalError: e,
          stackTrace:    StackTrace.current,
        );
      }
      throw InfrastructureException(
        message:      e.message ?? e.toString(),
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


  /// I disable 2FA by re-authenticating with the user's password.
  ///
  /// Re-authenticates via Firebase first (refreshes auth_time on the token),
  /// then calls the backend which verifies the re-authentication was recent.
  ///
  /// :param password: the user's current account password
  ///
  /// :throws AuthException: if the password is wrong
  /// :throws InfrastructureException: if any other error occurs
  Future<void> disable2FAByPassword(String password) async {
    // 1. Re-authenticate with Firebase to get a fresh auth_time token
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw AuthException.userNotFound();
    }

    try {
      final credential = EmailAuthProvider.credential(
        email:    user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      final mapped = AuthException.fromFirebaseCode(
        e.code,
        originalError: e,
        stackTrace: StackTrace.current,
      );
      throw mapped ?? InfrastructureException(
        message:      e.message ?? e.toString(),
        originalError: e,
        stackTrace:    StackTrace.current,
      );
    }

    // 2. Call the backend (auth_time is now fresh — within the 5-min window)
    try {
      await FirebaseFunctions.instance
          .httpsCallable('onDisable2FAByPassword')
          .call();
    } on FirebaseFunctionsException catch (e) {
      throw InfrastructureException(
        message:      e.message ?? e.toString(),
        originalError: e,
        stackTrace:    StackTrace.current,
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
    AppState.instance.setRegistering(true);
    try {
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
    } finally {
      AppState.instance.setRegistering(false);
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
      if (e.code == 'unauthenticated') {
        final msg = e.message?.toLowerCase() ?? '';
        if (msg.contains('2fa') || msg.contains('two_fa')) {
          throw AuthException.twoFARequired(
            originalError: e,
            stackTrace:    StackTrace.current,
          );
        }
      }
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
