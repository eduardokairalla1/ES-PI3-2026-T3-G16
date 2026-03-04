/// Eduardo Kairalla - 24024241 

/// --- Auth service ---

// --- IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mesclainvest/core/exceptions/auth.dart';
import 'package:mesclainvest/core/exceptions/infrastructure.dart';


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

    // error occurred in Firebase Authentication: throw a custom AuthException
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


  /// I register a new user with email and password, send a verification email,
  /// and immediately sign out so the user must verify before accessing the app.
  /// 
  /// :param email: the user's email
  /// :param password: the user's password
  /// 
  /// :throws AuthException: if the registration fails
  /// :throws InfrastructureException: if any other error occurs
  /// 
  /// :returns: void
  Future<void> register(String email, String password) async {

    // register with Firebase Authentication
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );

      // send email verification to the newly created user
      await result.user?.sendEmailVerification();

      // sign out immediately — user must verify email before accessing the app
      await _auth.signOut();
    }

    // error occurred in Firebase Authentication: throw a custom AuthException
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


  /// I resend a verification email to the given address by temporarily
  /// authenticating the user, sending the email, and immediately signing out.
  /// 
  /// :param email: the user's email
  /// :param password: the user's password
  /// 
  /// :throws AuthException: if re-authentication fails
  /// :throws InfrastructureException: if any other error occurs
  /// 
  /// :returns: void
  Future<void> resendVerificationEmail(String email, String password) async {

    // temporarily sign in to obtain a valid user object
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      // send the verification email
      await result.user?.sendEmailVerification();

      // sign out immediately after sending the email
      await _auth.signOut();
    }

    // error occurred in Firebase Authentication: throw a custom AuthException
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


  /// I sign out the current user.
  /// 
  /// :returns: void
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
