/// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  /// Check if error is a network error
  bool get isNetworkError => statusCode == null || statusCode == 0;

  /// Check if error is a server error (5xx)
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Check if error is a client error (4xx)
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Check if error is unauthorized
  bool get isUnauthorized => statusCode == 401;

  /// Check if error is forbidden
  bool get isForbidden => statusCode == 403;

  /// Check if error is not found
  bool get isNotFound => statusCode == 404;

  /// Check if error is validation error
  bool get isValidationError => statusCode == 422;

  @override
  String toString() {
    return 'ApiException(message: $message, statusCode: $statusCode)';
  }

  /// Get user-friendly message
  String get userMessage {
    if (isNetworkError) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (isServerError) {
      return 'Server error. Please try again later.';
    }

    if (isUnauthorized) {
      return 'Session expired. Please login again.';
    }

    if (isForbidden) {
      return 'You don\'t have permission to perform this action.';
    }

    if (isNotFound) {
      return 'The requested resource was not found.';
    }

    return message;
  }
}
