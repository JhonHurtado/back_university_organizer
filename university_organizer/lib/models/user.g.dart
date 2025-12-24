// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  phone: json['phone'] as String?,
  avatar: json['avatar'] as String?,
  timezone: json['timezone'] as String? ?? 'America/Bogota',
  language: json['language'] as String? ?? 'es',
  isActive: json['is_active'] as bool? ?? true,
  emailVerified: json['email_verified'] as bool? ?? false,
  emailVerifiedAt: json['email_verified_at'] == null
      ? null
      : DateTime.parse(json['email_verified_at'] as String),
  lastLoginAt: json['last_login_at'] == null
      ? null
      : DateTime.parse(json['last_login_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'phone': instance.phone,
  'avatar': instance.avatar,
  'timezone': instance.timezone,
  'language': instance.language,
  'is_active': instance.isActive,
  'email_verified': instance.emailVerified,
  'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
  'last_login_at': instance.lastLoginAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};
