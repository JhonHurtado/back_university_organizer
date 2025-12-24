// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
  id: json['id'] as String,
  careerId: json['career_id'] as String,
  semesterId: json['semester_id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  credits: (json['credits'] as num).toInt(),
  hoursPerWeek: (json['hours_per_week'] as num?)?.toInt(),
  subjectType:
      $enumDecodeNullable(_$SubjectTypeEnumMap, json['subject_type']) ??
      SubjectType.required,
  area: json['area'] as String?,
  gradeWeights: json['grade_weights'] as Map<String, dynamic>?,
  totalCuts: (json['total_cuts'] as num?)?.toInt() ?? 3,
  isElective: json['is_elective'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'career_id': instance.careerId,
  'semester_id': instance.semesterId,
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'credits': instance.credits,
  'hours_per_week': instance.hoursPerWeek,
  'subject_type': _$SubjectTypeEnumMap[instance.subjectType]!,
  'area': instance.area,
  'grade_weights': instance.gradeWeights,
  'total_cuts': instance.totalCuts,
  'is_elective': instance.isElective,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

const _$SubjectTypeEnumMap = {
  SubjectType.required: 'REQUIRED',
  SubjectType.elective: 'ELECTIVE',
  SubjectType.freeElective: 'FREE_ELECTIVE',
  SubjectType.complementary: 'COMPLEMENTARY',
};
