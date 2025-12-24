import 'package:dio/dio.dart';
import '../api_exception.dart';

/// Interceptor for handling and transforming errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Transform DioException to ApiException
    ApiException apiException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = ApiException(
          message: 'Connection timeout. Please try again.',
          statusCode: 408,
        );
        break;

      case DioExceptionType.badResponse:
        String message = 'An error occurred';

        if (data is Map<String, dynamic>) {
          message = data['message'] ?? data['error'] ?? message;
        }

        apiException = ApiException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
        break;

      case DioExceptionType.cancel:
        apiException = ApiException(
          message: 'Request was cancelled',
          statusCode: 499,
        );
        break;

      case DioExceptionType.connectionError:
        apiException = ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );
        break;

      case DioExceptionType.badCertificate:
        apiException = ApiException(
          message: 'Bad certificate. Connection is not secure.',
          statusCode: 495,
        );
        break;

      case DioExceptionType.unknown:
        apiException = ApiException(
          message: err.message ?? 'An unknown error occurred',
          statusCode: statusCode,
        );
        break;
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        type: err.type,
        response: err.response,
      ),
    );
  }
}
