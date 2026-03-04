/// --- Eduardo Kairalla - 24024241 ---

/// --- Custom Exceptions for Authentication ---

/// --- CODE ---

/// I represent an authentication exception
class AuthException implements Exception {

  // attributes
  final String message;
  final String code;
  final Object? originalError;
  final Object? stackTrace;


  // private constructor
  const AuthException._({
    required this.message,
    required this.code,
    this.originalError,
    this.stackTrace,
  });


  /// I create an AuthException for invalid credentials.
  /// 
  /// :param originalError: the original error that caused this exception
  /// :param stackTrace: the stack trace of the original error
  /// 
  /// :returns: an AuthException with invalid credentials message
  factory AuthException.invalidCredentials(
    {Object? originalError, Object? stackTrace}
  ) =>
    AuthException._(
      message: 'Email ou senha inválidos.',
      code: 'invalid_credentials',
      originalError: originalError,
      stackTrace: stackTrace,
    );


  /// I create an AuthException for invalid email.
  ///
  /// :param originalError: the original error that caused this exception
  /// :param stackTrace: the stack trace of the original error
  /// 
  /// :returns: an AuthException with invalid email message
  factory AuthException.invalidEmail(
    {Object? originalError, Object? stackTrace}
  ) =>
    AuthException._(
      message: 'Email inválido.',
      code: 'invalid_email',
      originalError: originalError,
      stackTrace: stackTrace,
    );


  /// I create an AuthException for email already in use.
  ///
  /// :param originalError: the original error that caused this exception
  /// :param stackTrace: the stack trace of the original error
  /// 
  /// :returns: an AuthException with email already in use message
  factory AuthException.emailAlreadyInUse(
    {Object? originalError, Object? stackTrace}
  ) =>
    AuthException._(
      message: 'Este email já está cadastrado.',
      code: 'email_already_in_use',
      originalError: originalError,
      stackTrace: stackTrace,
    );


  /// I create an AuthException for email not verified.
  ///
  /// :param originalError: the original error that caused this exception
  /// :param stackTrace: the stack trace of the original error
  /// 
  /// :returns: an AuthException with email not verified message
  factory AuthException.emailNotVerified(
    {Object? originalError, Object? stackTrace}
  ) =>
    AuthException._(
      message: 'Este e-mail ainda não foi verificado. '
               'Verifique sua caixa de entrada.',
      code: 'email_not_verified',
      originalError: originalError,
      stackTrace: stackTrace,
    );


  /// I create an AuthException for weak password.
  ///
  /// :param originalError: the original error that caused this exception
  /// :param stackTrace: the stack trace of the original error
  /// 
  /// :returns: an AuthException with weak password message
  factory AuthException.weakPassword(
    {Object? originalError, Object? stackTrace}
  ) =>
    AuthException._(
      message: 'A senha é muito fraca.',
      code: 'weak_password',
      originalError: originalError,
      stackTrace: stackTrace,
    );


  /// I create an AuthException for too many requests.
  ///
  /// :param originalError: the original error that caused this exception
  /// :param stackTrace: the stack trace of the original error
  ///
  /// :returns: an AuthException with too many requests message
  factory AuthException.tooManyRequests(
    {Object? originalError, Object? stackTrace}
  ) =>
    AuthException._(
      message: 'Muitas tentativas. Tente novamente mais tarde.',
      code: 'too_many_requests',
      originalError: originalError,
      stackTrace: stackTrace,
    );


  /// I create an AuthException for operation not allowed.
  ///
  /// :param originalError: the original error that caused this exception
  /// :param stackTrace: the stack trace of the original error
  /// 
  /// :returns: an AuthException with operation not allowed message
  factory AuthException.operationNotAllowed(
    {Object? originalError, Object? stackTrace}
  ) =>
    AuthException._(
      message: 'Operação não permitida.',
      code: 'operation_not_allowed',
      originalError: originalError,
      stackTrace: stackTrace,
    );


  /// I create an AuthException for user disabled.
  ///
  /// :param originalError: the original error that caused this exception
  /// :param stackTrace: the stack trace of the original error
  ///
  /// :returns: an AuthException with user disabled message
  factory AuthException.userDisabled(
    {Object? originalError, Object? stackTrace}
  ) =>
    AuthException._(
      message: 'Esta conta foi desativada.',
      code: 'user_disabled',
      originalError: originalError,
      stackTrace: stackTrace,
    );


  /// I create an AuthException from a FirebaseAuthException code.
  ///
  /// :param code: the FirebaseAuthException code.
  /// :param originalError: the original error that caused this exception
  /// :param stackTrace: the stack trace of the original error
  /// 
  /// :returns: an AuthException corresponding to the FirebaseAuthException
  ///           code, or null if the code is not recognized.
  static AuthException? fromFirebaseCode(
    String code, {Object? originalError, Object? stackTrace}
  ) {
    return switch (code) {
      'user-not-found' => AuthException.invalidCredentials(
        originalError: originalError,
        stackTrace: stackTrace
      ),
      'wrong-password' => AuthException.invalidCredentials(
        originalError: originalError,
        stackTrace: stackTrace
      ),
      'invalid-credential' => AuthException.invalidCredentials(
        originalError: originalError,
        stackTrace: stackTrace
      ),
      'invalid-email' => AuthException.invalidEmail(
        originalError: originalError,
        stackTrace: stackTrace
      ),
      'email-already-in-use' => AuthException.emailAlreadyInUse(
        originalError: originalError,
        stackTrace: stackTrace
      ),
      'weak-password' => AuthException.weakPassword(
        originalError: originalError,
        stackTrace: stackTrace
      ),
      'too-many-requests' => AuthException.tooManyRequests(
        originalError: originalError,
        stackTrace: stackTrace
      ),
      'operation-not-allowed' => AuthException.operationNotAllowed(
        originalError: originalError,
        stackTrace: stackTrace
      ),
      'user-disabled' => AuthException.userDisabled(
        originalError: originalError,
        stackTrace: stackTrace
      ),
      _ => null,
    };
  }


  /// I override the toString method to provide a better error message.
  /// 
  /// :returns: a string representation of this AuthException
  @override
  String toString() {
    return (
      'AuthException(code: $code, message: $message, '
      'originalError: $originalError, stackTrace: $stackTrace)'
    );
  }
}
