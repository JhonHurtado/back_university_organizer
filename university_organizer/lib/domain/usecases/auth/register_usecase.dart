import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/auth_response.dart';
import '../../repositories/auth_repository.dart';

/// Register use case
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await repository.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
