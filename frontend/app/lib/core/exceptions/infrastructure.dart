/// --- Eduardo Kairalla - 24024241 ---

/// --- Custom exceptions for Infrastructure ---

/// --- CODE ---

/// I represent an infrastructure exception.
class InfrastructureException implements Exception {

  // attributes
  final String message;
  final Object? originalError;
  final Object? stackTrace;

  // constructor
  const InfrastructureException({
    this.message = 'Ocorreu um erro inesperado. Tente novamente.',
    this.originalError,
    this.stackTrace,
  });


  /// I override the toString method to provide a better error message.
  /// 
  /// :returns: a string representation of this exception
  @override
  String toString() => (
    'InfrastructureException(message: $message, '
    'originalError: $originalError, stackTrace: $stackTrace)'
  );
}
