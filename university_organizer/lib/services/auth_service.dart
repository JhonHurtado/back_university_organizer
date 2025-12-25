import 'package:university_organizer/constants/app_constants.dart';

import '../models/user.dart';
import '../models/subscription.dart';
import '../models/menu_item.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Authentication response model
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final User user;
  final Subscription? subscription;
  final List<MenuItem> menu;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
    this.subscription,
    this.menu = const [],
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // El backend retorna { success, message, data: { access_token, refresh_token, token_type, expires_in, user, subscription, menu } }
    final data = json['data'] ?? json;

    // Debug logging
    print('🔍 Parsing AuthResponse:');
    print('  access_token: ${data['access_token']?.substring(0, 20)}...');
    print('  refresh_token: ${data['refresh_token']?.substring(0, 20)}...');
    print('  token_type: ${data['token_type']}');
    print('  expires_in: ${data['expires_in']}');
    print('  user: ${data['user']}');
    print('  subscription: ${data['subscription']}');
    print('  menu: ${data['menu'] != null ? 'Array of ${(data['menu'] as List).length} items' : 'null'}');

    return AuthResponse(
      accessToken: data['access_token'] ?? '',
      refreshToken: data['refresh_token'] ?? '',
      tokenType: data['token_type'] ?? 'Bearer',
      expiresIn: data['expires_in'] ?? 900,
      user: User.fromJson(data['user'] ?? {}),
      subscription: data['subscription'] != null
          ? Subscription.fromJson(data['subscription'])
          : null,
      menu: data['menu'] != null
          ? (data['menu'] as List).map((m) => MenuItem.fromJson(m)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user.toJson(),
      'subscription': subscription?.toJson(),
      'menu': menu.map((m) => m.toJson()).toList(),
    };
  }
}

/// Service for handling authentication
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          "client_id": AppConstants.oauthClientId,
          "client_secret": AppConstants.oauthClientSecret,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Register new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String? timezone,
    String? language,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          if (phone != null) 'phone': phone,
          if (timezone != null) 'timezone': timezone,
          if (language != null) 'language': language,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Login with Google OAuth (One-Tap)
  Future<AuthResponse> loginWithGoogle({required String credential}) async {
    try {
      final response = await _apiClient.post(
        '/auth/google',
        data: {
          'credential': credential,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh access token
  Future<Map<String, String>> refreshToken({required String refreshToken}) async {
    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      // El backend retorna { success, message, data: { accessToken, refreshToken } }
      final data = response.data['data'] ?? {};
      return {
        'accessToken': data['accessToken'] ?? '',
        'refreshToken': data['refreshToken'] ?? '',
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Ignore logout errors
    }
  }

  /// Logout all sessions
  Future<void> logoutAll() async {
    try {
      await _apiClient.post('/auth/logout-all');
    } catch (e) {
      // Ignore logout errors
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _apiClient.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verify email with token
  Future<void> verifyEmail({required String token}) async {
    try {
      await _apiClient.post(
        '/auth/verify-email',
        data: {
          'token': token,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _apiClient.post('/auth/resend-verification');
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return User.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    String? timezone,
    String? language,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/auth/profile',
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phone != null) 'phone': phone,
          if (avatar != null) 'avatar': avatar,
          if (timezone != null) 'timezone': timezone,
          if (language != null) 'language': language,
        },
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Invalid response from server',
          statusCode: response.statusCode,
        );
      }

      final data = response.data['data'] ?? response.data;
      return User.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
