import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'dart:convert';

/// Authentication state enum
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthState _authState = AuthState.initial;
  String? _accessToken;
  String? _refreshToken;
  User? _user;

  // Getters
  AuthState get authState => _authState;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLoading => _authState == AuthState.loading;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  User? get currentUser => _user;
  String? get userId => _user?.id;
  String? get userEmail => _user?.email;
  String? get userName => _user?.fullName;

  /// Initialize authentication state from secure storage
  Future<void> initialize() async {
    _authState = AuthState.loading;
    notifyListeners();

    try {
      _accessToken = await _secureStorage.read(key: _accessTokenKey);
      _refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      final userData = await _secureStorage.read(key: _userKey);

      if (userData != null) {
        _user = User.fromJson(jsonDecode(userData));
      }

      if (_accessToken != null && _user != null) {
        _authState = AuthState.authenticated;
      } else {
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      _authState = AuthState.unauthenticated;
    }

    notifyListeners();
  }

  /// Set authentication tokens and user data
  Future<void> setAuthData({
    required String accessToken,
    required String refreshToken,
    required User user,
  }) async {
    try {
      // Store in secure storage
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));

      // Update state
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _user = user;
      _authState = AuthState.authenticated;

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting auth data: $e');
    }
  }

  /// Update access token (for refresh token flow)
  Future<void> updateAccessToken(String newAccessToken) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
      _accessToken = newAccessToken;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating access token: $e');
    }
  }

  /// Clear authentication data and logout
  Future<void> logout() async {
    try {
      // Clear secure storage
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userKey);

      // Clear state
      _accessToken = null;
      _refreshToken = null;
      _user = null;
      _authState = AuthState.unauthenticated;

      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    _authState = loading ? AuthState.loading : _authState;
    notifyListeners();
  }

  /// Check if token is expired (basic implementation)
  /// TODO: Implement actual JWT token expiration check
  bool isTokenExpired() {
    // For now, return false. Implement JWT decoding later
    return false;
  }
}
