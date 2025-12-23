import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Server failures (API errors)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Error del servidor', String? code])
      : super(message, code);
}

/// Cache failures (Local storage errors)
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error de cache', String? code])
      : super(message, code);
}

/// Network failures (No internet connection)
class NetworkFailure extends Failure {
  const NetworkFailure(
      [String message = 'Error de conexión a internet', String? code])
      : super(message, code);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Error de autenticación', String? code])
      : super(message, code);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Error de validación', String? code])
      : super(message, code);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Recurso no encontrado', String? code])
      : super(message, code);
}

/// Unauthorized failures
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'No autorizado', String? code])
      : super(message, code);
}

/// Conflict failures (Duplicate data)
class ConflictFailure extends Failure {
  const ConflictFailure([String message = 'Conflicto de datos', String? code])
      : super(message, code);
}
