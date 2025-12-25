import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';

/// Base API client using Dio
class ApiClient {
  late final Dio _dio;

  // Callbacks for refresh token
  Future<Map<String, String>> Function(String refreshToken)? _onRefreshToken;
  Future<String?> Function()? _onGetRefreshToken;
  Future<void> Function(String accessToken, String? refreshToken)? _onUpdateTokens;
  Future<void> Function()? _onLogout;

  ApiClient({
    String? baseUrl,
    String? accessToken,
    Future<Map<String, String>> Function(String refreshToken)? onRefreshToken,
    Future<String?> Function()? onGetRefreshToken,
    Future<void> Function(String accessToken, String? refreshToken)? onUpdateTokens,
    Future<void> Function()? onLogout,
  }) : _onRefreshToken = onRefreshToken,
       _onGetRefreshToken = onGetRefreshToken,
       _onUpdateTokens = onUpdateTokens,
       _onLogout = onLogout {
    print('ApiClient initialized with baseUrl: ${baseUrl ?? AppConstants.apiBaseUrl}');
    print('Access Token: $accessToken');
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor(accessToken: accessToken));

    // Add refresh token interceptor if callbacks are provided
    if (onRefreshToken != null &&
        onGetRefreshToken != null &&
        onUpdateTokens != null &&
        onLogout != null) {
      _dio.interceptors.add(
        RefreshTokenInterceptor(
          dio: _dio,
          refreshTokenCallback: onRefreshToken,
          getRefreshTokenCallback: onGetRefreshToken,
          updateTokensCallback: onUpdateTokens,
          logoutCallback: onLogout,
        ),
      );
    }

    _dio.interceptors.add(ErrorInterceptor());

    // Only add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  /// Set refresh token callbacks
  void setRefreshTokenCallbacks({
    required Future<Map<String, String>> Function(String refreshToken) onRefreshToken,
    required Future<String?> Function() onGetRefreshToken,
    required Future<void> Function(String accessToken, String? refreshToken) onUpdateTokens,
    required Future<void> Function() onLogout,
  }) {
    _onRefreshToken = onRefreshToken;
    _onGetRefreshToken = onGetRefreshToken;
    _onUpdateTokens = onUpdateTokens;
    _onLogout = onLogout;

    // Remove old refresh token interceptor if exists
    _dio.interceptors.removeWhere((interceptor) => interceptor is RefreshTokenInterceptor);

    // Add new refresh token interceptor
    _dio.interceptors.insert(
      1, // After auth interceptor, before error interceptor
      RefreshTokenInterceptor(
        dio: _dio,
        refreshTokenCallback: onRefreshToken,
        getRefreshTokenCallback: onGetRefreshToken,
        updateTokensCallback: onUpdateTokens,
        logoutCallback: onLogout,
      ),
    );
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Update access token
  void updateToken(String? token) {
    // Find and update auth interceptor
    final authInterceptor = _dio.interceptors.firstWhere(
      (interceptor) => interceptor is AuthInterceptor,
      orElse: () => AuthInterceptor(),
    ) as AuthInterceptor;

    authInterceptor.updateToken(token);
  }

  /// Clear access token
  void clearToken() {
    updateToken(null);
  }

  // ==================== HTTP METHODS ====================

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fileKey: await MultipartFile.fromFile(filePath),
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Download file
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }
}
