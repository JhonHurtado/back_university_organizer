import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/subscription.dart';
import '../models/menu_item.dart';
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
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _tokenExpirationKey = 'token_expiration';
  static const String _userKey = 'user_data';
  static const String _subscriptionKey = 'subscription_data';
  static const String _menuKey = 'menu_data';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthState _authState = AuthState.initial;
  String? _accessToken;
  String? _refreshToken;
  String _tokenType = 'Bearer';
  int _expiresIn = 900;
  DateTime? _tokenExpiration;
  User? _user;
  Subscription? _subscription;
  List<MenuItem> _menu = [];

  // Getters
  AuthState get authState => _authState;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLoading => _authState == AuthState.loading;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String get tokenType => _tokenType;
  int get expiresIn => _expiresIn;
  DateTime? get tokenExpiration => _tokenExpiration;
  User? get currentUser => _user;
  Subscription? get subscription => _subscription;
  List<MenuItem> get menu => _menu;
  String? get userId => _user?.id;
  String? get userEmail => _user?.email;
  String? get userName => _user?.fullName;

  /// Initialize authentication state from secure storage
  Future<void> initialize() async {
    _authState = AuthState.loading;
    notifyListeners();

    try {
      // Load tokens from secure storage
      _accessToken = await _secureStorage.read(key: _accessTokenKey);
      _refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      // Load data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      _tokenType = prefs.getString(_tokenTypeKey) ?? 'Bearer';
      _expiresIn = prefs.getInt(_expiresInKey) ?? 900;

      final expirationMillis = prefs.getInt(_tokenExpirationKey);
      if (expirationMillis != null) {
        _tokenExpiration = DateTime.fromMillisecondsSinceEpoch(expirationMillis);
      }

      final userData = prefs.getString(_userKey);
      if (userData != null) {
        _user = User.fromJson(jsonDecode(userData));
      }

      final subscriptionData = prefs.getString(_subscriptionKey);
      if (subscriptionData != null) {
        _subscription = Subscription.fromJson(jsonDecode(subscriptionData));
      }

      final menuData = prefs.getString(_menuKey);
      if (menuData != null) {
        final menuList = jsonDecode(menuData) as List;
        _menu = menuList.map((m) => MenuItem.fromJson(m)).toList();
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
    String tokenType = 'Bearer',
    int expiresIn = 900,
    Subscription? subscription,
    List<MenuItem> menu = const [],
  }) async {
    try {
      // Store tokens in secure storage
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);

      // Calculate token expiration time
      final expiration = DateTime.now().add(Duration(seconds: expiresIn));

      // Store data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenTypeKey, tokenType);
      await prefs.setInt(_expiresInKey, expiresIn);
      await prefs.setInt(_tokenExpirationKey, expiration.millisecondsSinceEpoch);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      if (subscription != null) {
        await prefs.setString(_subscriptionKey, jsonEncode(subscription.toJson()));
      } else {
        await prefs.remove(_subscriptionKey);
      }

      if (menu.isNotEmpty) {
        await prefs.setString(_menuKey, jsonEncode(menu.map((m) => m.toJson()).toList()));
      } else {
        await prefs.remove(_menuKey);
      }

      // Update state
      _accessToken = accessToken;
      _refreshToken = refreshToken;
      _tokenType = tokenType;
      _expiresIn = expiresIn;
      _tokenExpiration = expiration;
      _user = user;
      _subscription = subscription;
      _menu = menu;
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

      // Update token expiration
      final expiration = DateTime.now().add(Duration(seconds: _expiresIn));
      _tokenExpiration = expiration;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_tokenExpirationKey, expiration.millisecondsSinceEpoch);

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating access token: $e');
    }
  }

  /// Update both access and refresh tokens (for refresh token flow)
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      _accessToken = accessToken;

      if (refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
        _refreshToken = refreshToken;
      }

      // Update token expiration
      final expiration = DateTime.now().add(Duration(seconds: _expiresIn));
      _tokenExpiration = expiration;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_tokenExpirationKey, expiration.millisecondsSinceEpoch);

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating tokens: $e');
    }
  }

  /// Clear authentication data and logout
  Future<void> logout() async {
    try {
      // Clear secure storage
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenTypeKey);
      await prefs.remove(_expiresInKey);
      await prefs.remove(_tokenExpirationKey);
      await prefs.remove(_userKey);
      await prefs.remove(_subscriptionKey);
      await prefs.remove(_menuKey);

      // Clear state
      _accessToken = null;
      _refreshToken = null;
      _tokenType = 'Bearer';
      _expiresIn = 900;
      _tokenExpiration = null;
      _user = null;
      _subscription = null;
      _menu = [];
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

  /// Check if token is expired
  bool isTokenExpired() {
    if (_tokenExpiration == null) return false;
    return DateTime.now().isAfter(_tokenExpiration!);
  }

  /// Get remaining time until token expires
  Duration? getTokenRemainingTime() {
    if (_tokenExpiration == null) return null;
    final now = DateTime.now();
    if (now.isAfter(_tokenExpiration!)) return Duration.zero;
    return _tokenExpiration!.difference(now);
  }
}
