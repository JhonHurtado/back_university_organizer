/// Form validators
class Validators {
  Validators._();

  /// Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  /// Password validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// Confirm password validator
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Required field validator
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    return null;
  }

  /// Name validator
  static String? name(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'El nombre'} es requerido';
    }

    if (value.length < 2) {
      return '${fieldName ?? 'El nombre'} debe tener al menos 2 caracteres';
    }

    return null;
  }

  /// Min length validator
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $minLength caracteres';
    }

    return null;
  }

  /// Max length validator
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'Este campo'} debe tener máximo $maxLength caracteres';
    }

    return null;
  }
}
