import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_state_notifier.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_message.dart';
import 'register_screen_fresh.dart';

class LoginScreenFresh extends ConsumerStatefulWidget {
  const LoginScreenFresh({super.key});

  @override
  ConsumerState<LoginScreenFresh> createState() => _LoginScreenFreshState();
}

class _LoginScreenFreshState extends ConsumerState<LoginScreenFresh> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authNotifier = ref.read(authStateNotifierProvider.notifier);

      final success = await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('¡Bienvenido de nuevo!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.card,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Título
                  Text(
                    '¡Hola de nuevo!',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Ingresa para continuar tu viaje académico',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),

                  // Error message
                  if (authState.error != null) ...[
                    ErrorMessage(
                      message: authState.error!,
                      onRetry: () {
                        ref
                            .read(authStateNotifierProvider.notifier)
                            .clearError();
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                  ],

                  // Email field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      color: AppColors.card,
                    ),
                    child: CustomTextField(
                      hint: 'tu@email.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),
                      validator: Validators.email,
                      enabled: !authState.isLoading,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),

                  // Password field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      color: AppColors.card,
                    ),
                    child: CustomTextField(
                      hint: '••••••••',
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                      ),
                      validator: Validators.password,
                      enabled: !authState.isLoading,
                      onChanged: (_) {
                        if (authState.error != null) {
                          ref
                              .read(authStateNotifierProvider.notifier)
                              .clearError();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              // Navigate to forgot password
                            },
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Login button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: authState.isLoading ? null : _handleLogin,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        child: Container(
                          height: AppDimensions.buttonHeightMd,
                          alignment: Alignment.center,
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Iniciar sesión',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMd,
                        ),
                        child: Text(
                          'o continúa con',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Google Sign In button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      border: Border.all(color: AppColors.border),
                      color: AppColors.card,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: authState.isLoading
                            ? null
                            : () {
                                // Google Sign In
                              },
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        child: Container(
                          height: AppDimensions.buttonHeightMd,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.g_mobiledata_rounded, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Google',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreenFresh(),
                                  ),
                                );
                              },
                        child: Text(
                          '¡Regístrate gratis!',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
