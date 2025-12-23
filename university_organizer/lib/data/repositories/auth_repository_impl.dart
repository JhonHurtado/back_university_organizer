import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save tokens
      await localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return Right(result.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final result = await remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
      );

      // Save tokens
      await localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return Right(result.toEntity());
    } on ConflictException catch (e) {
      return Left(ConflictFailure(e.message, e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken) async {
    try {
      final result = await remoteDataSource.refreshToken(refreshToken);

      // Save new tokens
      await localDataSource.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );

      return Right(result.toEntity());
    } on UnauthorizedException catch (e) {
      // Clear tokens on refresh failure
      await localDataSource.clearTokens();
      return Left(AuthFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearTokens();
      return const Right(null);
    } on NetworkException catch (e) {
      // Even if network fails, clear local tokens
      await localDataSource.clearTokens();
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      // Even if server fails, clear local tokens
      await localDataSource.clearTokens();
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      await localDataSource.clearTokens();
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, void>> logoutAll() async {
    try {
      await remoteDataSource.logoutAll();
      await localDataSource.clearTokens();
      return const Right(null);
    } on NetworkException catch (e) {
      await localDataSource.clearTokens();
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      await localDataSource.clearTokens();
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      await localDataSource.clearTokens();
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final result = await remoteDataSource.getCurrentUser();
      return Right(result.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await localDataSource.hasTokens();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await localDataSource.getAccessToken();
    } on CacheException catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await localDataSource.getRefreshToken();
    } on CacheException catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await localDataSource.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> clearTokens() async {
    await localDataSource.clearTokens();
  }
}
