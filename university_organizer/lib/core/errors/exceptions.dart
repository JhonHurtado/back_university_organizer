/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message ${code != null ? '($code)' : ''}';
}

/// Server exception
class ServerException extends AppException {
  const ServerException([String message = 'Error del servidor', String? code])
      : super(message, code);
}

/// Cache exception
class CacheException extends AppException {
  const CacheException([String message = 'Error de cache', String? code])
      : super(message, code);
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException(
      [String message = 'Sin conexión a internet', String? code])
      : super(message, code);
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException([String message = 'Error de autenticación', String? code])
      : super(message, code);
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException([String message = 'Error de validación', String? code])
      : super(message, code);
}

/// Unauthorized exception
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'No autorizado', String? code])
      : super(message, code);
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException([String message = 'No encontrado', String? code])
      : super(message, code);
}

/// Conflict exception
class ConflictException extends AppException {
  const ConflictException([String message = 'Conflicto', String? code])
      : super(message, code);
}
