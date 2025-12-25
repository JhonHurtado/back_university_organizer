import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor for handling token refresh on 401 responses
class RefreshTokenInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final Future<Map<String, String>> Function(String refreshToken) _refreshTokenCallback;
  final Future<String?> Function() _getRefreshTokenCallback;
  final Future<void> Function(String accessToken, String? refreshToken) _updateTokensCallback;
  final Future<void> Function() _logoutCallback;

  RefreshTokenInterceptor({
    required Dio dio,
    required Future<Map<String, String>> Function(String refreshToken) refreshTokenCallback,
    required Future<String?> Function() getRefreshTokenCallback,
    required Future<void> Function(String accessToken, String? refreshToken) updateTokensCallback,
    required Future<void> Function() logoutCallback,
  })  : _dio = dio,
        _refreshTokenCallback = refreshTokenCallback,
        _getRefreshTokenCallback = getRefreshTokenCallback,
        _updateTokensCallback = updateTokensCallback,
        _logoutCallback = logoutCallback;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 Unauthorized
    if (err.response?.statusCode == 401) {
      try {
        debugPrint('🔄 Token expired, attempting to refresh...');

        // Get refresh token
        final refreshToken = await _getRefreshTokenCallback();

        if (refreshToken == null || refreshToken.isEmpty) {
          debugPrint('❌ No refresh token available, logging out');
          await _logoutCallback();
          return handler.next(err);
        }

        // Attempt to refresh the token
        final tokens = await _refreshTokenCallback(refreshToken);
        final newAccessToken = tokens['accessToken'];
        final newRefreshToken = tokens['refreshToken'];

        if (newAccessToken == null || newAccessToken.isEmpty) {
          debugPrint('❌ Failed to refresh token, logging out');
          await _logoutCallback();
          return handler.next(err);
        }

        debugPrint('✅ Token refreshed successfully');

        // Update tokens
        await _updateTokensCallback(newAccessToken, newRefreshToken);

        // Update the failed request with new token
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';

        // Retry the original request
        debugPrint('🔄 Retrying original request with new token');
        try {
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          debugPrint('❌ Failed to retry request: $e');
          return handler.next(err);
        }
      } catch (e) {
        debugPrint('❌ Error during token refresh: $e');
        // If refresh fails, logout user
        await _logoutCallback();
        return handler.next(err);
      }
    }

    // For other errors, continue with normal error handling
    return handler.next(err);
  }
}
