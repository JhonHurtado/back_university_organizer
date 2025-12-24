import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthState _authState = AuthState.initial;
  String? _accessToken;
  String? _refreshToken;
  String? _userId;
  String? _userEmail;
  String? _userName;

  // Getters
  AuthState get authState => _authState;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLoading => _authState == AuthState.loading;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  /// Initialize authentication state from secure storage
  Future<void> initialize() async {
    _authState = AuthState.loading;
    notifyListeners();

    try {
      _accessToken = await _secureStorage.read(key: _accessTokenKey);
      _refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      _userId = await _secureStorage.read(key: _userIdKey);
      _userEmail = await _secureStorage.read(key: _userEmailKey);

      if (_accessToken != null && _userId != null) {
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
    required String userId,
    String? email,
    String? name,
  }) async {
    try {
      // Store in secure storage
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      await _secureStorage.write(key: _userIdKey, value: userId);

      if (email != null) {
        await _secureStorage.write(key: _userEmailKey, value: email);
      }

      // Update state
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _userId = userId;
      _userEmail = email;
      _userName = name;
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
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userEmailKey);

      // Clear state
      _accessToken = null;
      _refreshToken = null;
      _userId = null;
      _userEmail = null;
      _userName = null;
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
