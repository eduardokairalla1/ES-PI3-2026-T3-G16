/// Eduardo Kairalla - 24024241

/// --- Auth service ---

// --- IMPORTS ---
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  /// :returns: void
  Future<void> signIn(String email, String password) async {

    // sign in with Firebase Authentication
    try {
      await _auth.signInWithEmailAndPassword(
        email: email, password: password
      );
    }

    // error occurred in Firebase Authentication: trow a custom AuthException
    on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(
        e.code,
        originalError: e,
        stackTrace: StackTrace.current
      ) ?? InfrastructureException(
        originalError: e,
        stackTrace: StackTrace.current
      );
    }

    // any other error: throw a InfrastructureException
    catch (e) {
      throw InfrastructureException(
        message: e.toString(),
        originalError: e,
        stackTrace: StackTrace.current
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

    // register with Firebase Authentication
    try {
        await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password
        );

        // call onUserCreated with the registered user's data
        await FirebaseFunctions.instance
            .httpsCallable('onUserCreated')
            .call({
                'fullName': fullName,
                'cpf': cpf,
                'phone': phone,
                'birthDate': birthDate,
            });
    }

    // error occurred in Firebase Authentication: trow a custom AuthException
    on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(
        e.code,
        originalError: e,
        stackTrace: StackTrace.current
      ) ?? InfrastructureException(
        originalError: e,
        stackTrace: StackTrace.current
      );
    }

    // any other error: throw a generic InfrastructureException
    catch (e) {
      throw InfrastructureException(
        message: e.toString(),
        originalError: e,
        stackTrace: StackTrace.current
      );
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
      await _auth.sendPasswordResetEmail(email: email);
    }

    // error occurred in Firebase Authentication: throw a custom AuthException
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

    // any other error: throw an InfrastructureException
    catch (e) {
      throw InfrastructureException(
        message:      e.toString(),
        originalError: e,
        stackTrace:    StackTrace.current,
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
    }

    // any error: throw an InfrastructureException
    catch (e) {
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
