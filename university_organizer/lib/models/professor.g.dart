// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Professor _$ProfessorFromJson(Map<String, dynamic> json) => Professor(
  id: json['id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  office: json['office'] as String?,
  department: json['department'] as String?,
  title: json['title'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProfessorToJson(Professor instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'office': instance.office,
  'department': instance.department,
  'title': instance.title,
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
