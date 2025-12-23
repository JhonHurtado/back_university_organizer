import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/errors/exceptions.dart';

/// Authentication local data source for storing tokens securely
abstract class AuthLocalDataSource {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
  Future<bool> hasTokens();
}

/// Implementation of AuthLocalDataSource
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: _accessTokenKey);
    } catch (e) {
      throw const CacheException('Error al obtener access token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw const CacheException('Error al obtener refresh token');
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        storage.write(key: _accessTokenKey, value: accessToken),
        storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
    } catch (e) {
      throw const CacheException('Error al guardar tokens');
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        storage.delete(key: _accessTokenKey),
        storage.delete(key: _refreshTokenKey),
      ]);
    } catch (e) {
      throw const CacheException('Error al limpiar tokens');
    }
  }

  @override
  Future<bool> hasTokens() async {
    try {
      final accessToken = await storage.read(key: _accessTokenKey);
      final refreshToken = await storage.read(key: _refreshTokenKey);
      return accessToken != null && refreshToken != null;
    } catch (e) {
      return false;
    }
  }
}
