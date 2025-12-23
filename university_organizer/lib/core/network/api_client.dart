import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'auth_interceptor.dart';

/// Proveedor de instancia de Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Accept': ApiConstants.accept,
      },
    ),
  );

  // Agregar interceptores
  dio.interceptors.addAll([
    AuthInterceptor(),
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  ]);

  return dio;
});

/// Clase cliente API para realizar peticiones HTTP
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// Petición GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Petición POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Petición PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Petición PATCH
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Petición DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Manejar errores de Dio y convertirlos a excepciones de la app
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Tiempo de espera agotado');

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return const AppException('Petición cancelada');

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return const NetworkException('Sin conexión a internet');
        }
        return ServerException(error.message ?? 'Error desconocido');

      default:
        return ServerException(error.message ?? 'Error desconocido');
    }
  }

  /// Manejar errores de respuesta HTTP
  AppException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final message = data is Map ? (data['message'] ?? data['error']) : null;
    final errorCode = data is Map ? data['code'] : null;

    switch (statusCode) {
      case 400:
        return ValidationException(
            message ?? 'Petición inválida', errorCode);
      case 401:
        return UnauthorizedException(
            message ?? 'No autorizado', errorCode);
      case 403:
        return AuthException(
            message ?? 'Acceso denegado', errorCode);
      case 404:
        return NotFoundException(
            message ?? 'Recurso no encontrado', errorCode);
      case 409:
        return ConflictException(
            message ?? 'Conflicto de datos', errorCode);
      case 500:
      case 502:
      case 503:
        return ServerException(
            message ?? 'Error del servidor', errorCode);
      default:
        return ServerException(
            message ?? 'Error del servidor', errorCode);
    }
  }
}

/// Proveedor de ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
