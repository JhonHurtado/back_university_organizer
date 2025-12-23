import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_state_notifier.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/error_message.dart';

class RegisterScreenFresh extends ConsumerStatefulWidget {
  const RegisterScreenFresh({super.key});

  @override
  ConsumerState<RegisterScreenFresh> createState() =>
      _RegisterScreenFreshState();
}

class _RegisterScreenFreshState extends ConsumerState<RegisterScreenFresh> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.celebration, color: Colors.white),
                SizedBox(width: 12),
                Text('¡Cuenta creada con éxito!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
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
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.background,
              AppColors.card,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: authState.isLoading
                            ? null
                            : () => Navigator.pop(context),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Contenido scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingLg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Título
                        Text(
                          '¡Únete ahora!',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Crea tu cuenta y comienza a organizar tu vida académica',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

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

                        // Campo de nombre completo
                        _buildInputField(
                          child: CustomTextField(
                            hint: 'Nombre Completo',
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: AppColors.primary,
                            ),
                            validator: (value) =>
                                Validators.name(value, 'El nombre completo'),
                            enabled: !authState.isLoading,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),

                        // Email field
                        _buildInputField(
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
                        _buildInputField(
                          child: CustomTextField(
                            hint: 'Mínimo 6 caracteres',
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.primary,
                            ),
                            validator: Validators.password,
                            enabled: !authState.isLoading,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),

                        // Confirm Password field
                        _buildInputField(
                          child: CustomTextField(
                            hint: 'Confirma tu contraseña',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.primary,
                            ),
                            validator: (value) => Validators.confirmPassword(
                                value, _passwordController.text),
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
                        const SizedBox(height: AppDimensions.spacingXl),

                        // Register Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
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
                              onTap: authState.isLoading ? null : _handleRegister,
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusLg),
                              child: Container(
                                height: AppDimensions.buttonHeightMd,
                                alignment: Alignment.center,
                                child: authState.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.rocket_launch,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            '¡Crear mi cuenta!',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),

                        // Términos y condiciones
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLg),
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Al registrarte, aceptas nuestros Términos y Condiciones',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.info,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXl),

                        // Already have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¿Ya tienes cuenta? ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: Text(
                                'Inicia sesión',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        color: AppColors.card,
      ),
      child: child,
    );
  }
}
