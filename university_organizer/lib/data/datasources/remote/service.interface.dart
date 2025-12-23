import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

/// Interfaz de servicios para todas las llamadas a la API
/// Esta clase centraliza todas las peticiones HTTP al backend
abstract class ServiceInterface {
  // Servicios de Autenticación
  Future<Response> login({
    required String email,
    required String password,
  });

  Future<Response> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String timezone,
    required String language,
  });

  Future<Response> refreshToken(String refreshToken);

  Future<Response> logout();

  Future<Response> logoutAll();

  Future<Response> getCurrentUser();

  Future<Response> googleAuth();

  Future<Response> googleCallback(String code);

  // Futuro: Agregar más métodos de servicios según sea necesario
  // - Servicios de calificaciones
  // - Servicios de horarios
  // - Servicios de notificaciones
  // - Servicios de pagos
  // - etc.
}

/// Implementación de ServiceInterface
class ServiceInterfaceImpl implements ServiceInterface {
  final ApiClient _apiClient;

  ServiceInterfaceImpl(this._apiClient);

  // ========== Servicios de Autenticación ==========

  @override
  Future<Response> login({
    required String email,
    required String password,
  }) {
    return _apiClient.post(
      ApiConstants.login,
      data: {
        'client_id': ApiConstants.clientId,
        'client_secret': ApiConstants.clientSecret,
        'email': email,
        'password': password,
      },
    );
  }

  @override
  Future<Response> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String timezone,
    required String language,
  }) {
    return _apiClient.post(
      ApiConstants.register,
      data: {
        'client_id': ApiConstants.clientId,
        'client_secret': ApiConstants.clientSecret,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'timezone': timezone,
        'language': language,
      },
    );
  }

  @override
  Future<Response> refreshToken(String refreshToken) {
    return _apiClient.post(
      ApiConstants.refresh,
      data: {
        'client_id': ApiConstants.clientId,
        'client_secret': ApiConstants.clientSecret,
        'refresh_token': refreshToken,
      },
    );
  }

  @override
  Future<Response> logout() {
    return _apiClient.post(ApiConstants.logout);
  }

  @override
  Future<Response> logoutAll() {
    return _apiClient.post(ApiConstants.logoutAll);
  }

  @override
  Future<Response> getCurrentUser() {
    return _apiClient.get(ApiConstants.me);
  }

  @override
  Future<Response> googleAuth() {
    return _apiClient.get(ApiConstants.googleAuth);
  }

  @override
  Future<Response> googleCallback(String code) {
    return _apiClient.post(
      ApiConstants.googleCallback,
      data: {
        'client_id': ApiConstants.clientId,
        'client_secret': ApiConstants.clientSecret,
        'code': code,
      },
    );
  }

  // ========== Servicios Futuros ==========
  // Agregar más implementaciones de servicios a medida que la app crezca
  // Ejemplo:
  // Future<Response> getGrades() { ... }
  // Future<Response> getSchedules() { ... }
  // Future<Response> getNotifications() { ... }
}
