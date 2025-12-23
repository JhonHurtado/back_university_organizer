import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import 'auth_providers.dart';

/// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthStateNotifier(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
  ) : super(const AuthState());

  /// Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginUseCase(email: email, password: password);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
        return false;
      },
      (authResponse) {
        state = state.copyWith(
          isLoading: false,
          user: authResponse.user,
          error: null,
          isAuthenticated: true,
        );
        return true;
      },
    );
  }

  /// Register
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _registerUseCase(
      email: email,
      password: password,
      fullName: fullName,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
        return false;
      },
      (authResponse) {
        state = state.copyWith(
          isLoading: false,
          user: authResponse.user,
          error: null,
          isAuthenticated: true,
        );
        return true;
      },
    );
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    await _logoutUseCase();

    state = const AuthState(
      isLoading: false,
      isAuthenticated: false,
    );
  }

  /// Get current user
  Future<void> getCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          isAuthenticated: false,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          error: null,
          isAuthenticated: true,
        );
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth state notifier provider
final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);

  return AuthStateNotifier(
    loginUseCase,
    registerUseCase,
    logoutUseCase,
    getCurrentUserUseCase,
  );
});
