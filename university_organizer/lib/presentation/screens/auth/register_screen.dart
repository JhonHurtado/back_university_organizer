import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_state_notifier.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_message.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authNotifier = ref.read(authStateNotifierProvider.notifier);

      final success = await authNotifier.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      if (success && mounted) {
        // Navigate to home screen or show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: authState.isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spacingLg),

                // Title
                Text(
                  'Crea tu cuenta',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),

                Text(
                  'Completa el formulario para registrarte',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
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

                // Full name field
                CustomTextField(
                  label: 'Nombre Completo',
                  hint: 'Tu nombre completo',
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) => Validators.name(value, 'El nombre completo'),
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: AppDimensions.spacingLg),

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
                  hint: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: Validators.password,
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Confirm password field
                CustomTextField(
                  label: 'Confirmar contraseña',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (value) =>
                      Validators.confirmPassword(value, _passwordController.text),
                  enabled: !authState.isLoading,
                  onChanged: (_) {
                    if (authState.error != null) {
                      ref
                          .read(authStateNotifierProvider.notifier)
                          .clearError();
                    }
                  },
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Register button
                CustomButton(
                  text: 'Registrarse',
                  onPressed: authState.isLoading ? null : _handleRegister,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Terms and conditions
                Text(
                  'Al registrarte, aceptas nuestros Términos y Condiciones y Política de Privacidad',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingXl),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes una cuenta? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed:
                          authState.isLoading ? null : () => Navigator.pop(context),
                      child: Text(
                        'Inicia sesión',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
