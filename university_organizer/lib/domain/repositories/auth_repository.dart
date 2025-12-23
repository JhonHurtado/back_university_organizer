import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/auth_response.dart';
import '../entities/user.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  /// Register new user
  Future<Either<Failure, AuthResponse>> register({
    required String email,
    required String password,
    required String fullName,
  });

  /// Refresh access token
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken);

  /// Logout current session
  Future<Either<Failure, void>> logout();

  /// Logout all sessions
  Future<Either<Failure, void>> logoutAll();

  /// Get current user
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get stored access token
  Future<String?> getAccessToken();

  /// Get stored refresh token
  Future<String?> getRefreshToken();

  /// Save tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Clear tokens
  Future<void> clearTokens();
}
