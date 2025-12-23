/// Constantes de API para la aplicación University Organizer
class ApiConstants {
  ApiConstants._();

  // URL base - Cambiar esto para producción
  static const String baseUrl = 'http://192.168.101.12:3030/api/v1';

  // Versión de la API
  static const String apiVersion = 'v1';

  // Duraciones de timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Credenciales del cliente (se envían en el body de las peticiones de auth)
  static const String clientId = 'bf799b5ee095797d4d3c9f4741fecdae';
  static const String clientSecret = '1aa4ff8d1f811c6e050914ad35d45d7a6ceb72057f616abbebe22f04a9deaeff';

  // Endpoints de autenticación
  static const String authBase = '/auth';
  static const String login = '$authBase/login';
  static const String register = '$authBase/register';
  static const String refresh = '$authBase/refresh';
  static const String logout = '$authBase/logout';
  static const String logoutAll = '$authBase/logout-all';
  static const String me = '$authBase/me';
  static const String googleAuth = '$authBase/google';
  static const String googleRedirect = '$authBase/google/redirect';
  static const String googleCallback = '$authBase/google/callback';

  // Headers HTTP
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
