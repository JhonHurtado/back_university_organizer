import 'package:equatable/equatable.dart';

/// Entidad de usuario
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatar;
  final bool emailVerified;
  final UserSubscription? subscription;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatar,
    this.emailVerified = false,
    this.subscription,
  });

  /// Obtener el primer nombre del fullName
  String get firstName {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts[0] : fullName;
  }

  /// Obtener el apellido del fullName
  String get lastName {
    final parts = fullName.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatar,
        emailVerified,
        subscription,
      ];
}

/// User subscription entity
class UserSubscription extends Equatable {
  final String status;
  final String plan;

  const UserSubscription({
    required this.status,
    required this.plan,
  });

  @override
  List<Object?> get props => [status, plan];
}
