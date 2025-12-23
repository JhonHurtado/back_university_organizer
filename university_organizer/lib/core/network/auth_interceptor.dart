import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Interceptor de autenticación para agregar headers de autorización a las peticiones
class AuthInterceptor extends Interceptor {
  static const _storage = FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Agregar token de acceso si está disponible (excepto para endpoints de auth)
    // Nota: Las credenciales del cliente ahora se incluyen en el body para endpoints de auth
    if (!_isAuthEndpoint(options.path)) {
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Manejar 401 No autorizado - token expirado
    if (err.response?.statusCode == 401) {
      // TODO: Implementar lógica de refresh de token aquí
      // Por ahora, solo pasar el error
      handler.next(err);
    } else {
      handler.next(err);
    }
  }

  /// Verificar si el endpoint es un endpoint de autenticación
  /// Los endpoints de auth no necesitan Bearer token (usan credenciales de cliente en body)
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/google');
  }
}
