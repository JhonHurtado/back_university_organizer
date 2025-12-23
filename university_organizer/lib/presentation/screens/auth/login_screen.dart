import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_state_notifier.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_message.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
        // Navigate to home screen
        // Navigator.pushReplacement(...)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spacingXxl),

                // Logo or app name
                const Icon(
                  Icons.school_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Title
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingSm),

                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingXl),

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
                CustomTextField(
                  label: 'Correo electrónico',
                  hint: 'ejemplo@correo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.email,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Password field
                CustomTextField(
                  label: 'Contraseña',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline),
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
                const SizedBox(height: AppDimensions.spacingMd),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: authState.isLoading ? null : () {
                      // Navigate to forgot password
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Login button
                CustomButton(
                  text: 'Iniciar sesión',
                  onPressed: authState.isLoading ? null : _handleLogin,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMd,
                      ),
                      child: Text(
                        'o',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Register button
                CustomButton(
                  text: 'Crear cuenta',
                  type: CustomButtonType.outlined,
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                ),
                const SizedBox(height: AppDimensions.spacingLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
