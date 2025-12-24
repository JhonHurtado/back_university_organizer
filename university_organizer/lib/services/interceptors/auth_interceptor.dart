import 'package:dio/dio.dart';

/// Interceptor to add authentication token to requests
class AuthInterceptor extends Interceptor {
  String? _accessToken;

  AuthInterceptor({String? accessToken}) : _accessToken = accessToken;

  /// Update access token
  void updateToken(String? token) {
    _accessToken = token;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authorization header if token exists
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      // Token might be expired, you can trigger token refresh here
      // For now, just pass the error
    }

    super.onError(err, handler);
  }
}
