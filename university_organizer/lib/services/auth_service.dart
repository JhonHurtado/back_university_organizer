import '../models/user.dart';
import 'api_client.dart';
import 'api_exception.dart';
import '../constants/app_constants.dart';

/// Authentication response model
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refreshToken'] ?? '',
      user: User.fromJson(json['user']),
    );
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
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          if (phone != null) 'phone': phone,
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

  /// Login with Google OAuth
  Future<AuthResponse> loginWithGoogle({required String idToken}) async {
    try {
      final response = await _apiClient.post(
        '/auth/google',
        data: {'id_token': idToken},
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
  Future<AuthResponse> refreshToken({required String refreshToken}) async {
    try {
      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
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

  /// Logout
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Ignore logout errors
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _apiClient.post('/auth/forgot-password', data: {'email': email});
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
        data: {'token': token, 'password': newPassword},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verify email with token
  Future<void> verifyEmail({required String token}) async {
    try {
      await _apiClient.post('/auth/verify-email', data: {'token': token});
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

      return User.fromJson(response.data);
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
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
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

      return User.fromJson(response.data);
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
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
