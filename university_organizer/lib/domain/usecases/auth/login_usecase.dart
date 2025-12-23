import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/auth_response.dart';
import '../../repositories/auth_repository.dart';

/// Login use case
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
