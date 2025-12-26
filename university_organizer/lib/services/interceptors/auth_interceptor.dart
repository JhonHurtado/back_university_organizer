import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor to add authentication token to requests
class AuthInterceptor extends Interceptor {
  String? _accessToken;

  AuthInterceptor({String? accessToken}) : _accessToken = accessToken;

  /// Update access token
  void updateToken(String? token) {
    debugPrint('🔑 AuthInterceptor: Token updated');
    debugPrint('  Old token: ${_accessToken?.substring(0, 20) ?? 'null'}...');
    debugPrint('  New token: ${token?.substring(0, 20) ?? 'null'}...');
    _accessToken = token;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add authorization header if token exists
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      debugPrint('🔑 AuthInterceptor: Adding Authorization header');
      debugPrint('  Token: ${_accessToken!.substring(0, 20)}...');
      options.headers['Authorization'] = 'Bearer $_accessToken';
    } else {
      debugPrint('⚠️  AuthInterceptor: No token available for ${options.path}');
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
