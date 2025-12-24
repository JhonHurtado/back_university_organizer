import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model representing a registered user
@JsonSerializable()
class User {
  final String id;
  final String email;

  // Backend returns fullName in login, but first_name/last_name in profile
  @JsonKey(name: 'fullName')
  final String? fullNameFromBackend;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  final String? phone;
  final String? avatar;
  final String? timezone;
  final String? language;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  @JsonKey(name: 'email_verified')
  final bool? emailVerified;

  @JsonKey(name: 'email_verified_at')
  final DateTime? emailVerifiedAt;

  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.email,
    this.fullNameFromBackend,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.timezone,
    this.language,
    this.isActive,
    this.emailVerified,
    this.emailVerifiedAt,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Get full name (prefer fullNameFromBackend, fallback to firstName + lastName)
  String get fullName {
    if (fullNameFromBackend != null && fullNameFromBackend!.isNotEmpty) {
      return fullNameFromBackend!;
    }
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Get initials
  String get initials {
    // If we have fullNameFromBackend, split it
    if (fullNameFromBackend != null && fullNameFromBackend!.isNotEmpty) {
      final parts = fullNameFromBackend!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
      } else if (parts.length == 1 && parts[0].isNotEmpty) {
        return parts[0][0].toUpperCase();
      }
    }

    // Fallback to firstName/lastName
    final first = (firstName != null && firstName!.isNotEmpty) ? firstName![0] : '';
    final last = (lastName != null && lastName!.isNotEmpty) ? lastName![0] : '';
    return '$first$last'.toUpperCase();
  }

  /// JSON serialization
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Create copy with modifications
  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatar,
    String? timezone,
    String? language,
    bool? isActive,
    bool? emailVerified,
    DateTime? emailVerifiedAt,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
