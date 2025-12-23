import '../../../core/errors/exceptions.dart';
import '../../models/auth_response_model.dart';
import '../../models/user_model.dart';
import 'service.interface.dart';

/// Fuente de datos remota de autenticación
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<AuthResponseModel> refreshToken(String refreshToken);

  Future<void> logout();

  Future<void> logoutAll();

  Future<UserModel> getCurrentUser();
}

/// Implementación de AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ServiceInterface _serviceInterface;

  AuthRemoteDataSourceImpl(this._serviceInterface);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _serviceInterface.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AuthResponseModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al iniciar sesión',
          response.data['code'],
        );
      }
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado al iniciar sesión');
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _serviceInterface.register(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return AuthResponseModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al registrar usuario',
          response.data['code'],
        );
      }
    } catch (e) {
      if (e is ServerException ||
          e is ConflictException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado al registrar usuario');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await _serviceInterface.refreshToken(refreshToken);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AuthResponseModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al refrescar token',
          response.data['code'],
        );
      }
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado al refrescar token');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await _serviceInterface.logout();

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? 'Error al cerrar sesión',
          response.data['code'],
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado al cerrar sesión');
    }
  }

  @override
  Future<void> logoutAll() async {
    try {
      final response = await _serviceInterface.logoutAll();

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? 'Error al cerrar todas las sesiones',
          response.data['code'],
        );
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado al cerrar todas las sesiones');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _serviceInterface.getCurrentUser();

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Error al obtener usuario',
          response.data['code'],
        );
      }
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Error inesperado al obtener usuario');
    }
  }
}
