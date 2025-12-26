// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Enrollment _$EnrollmentFromJson(Map<String, dynamic> json) => Enrollment(
  id: json['id'] as String,
  careerId: json['careerId'] as String,
  subjectId: json['subjectId'] as String,
  periodId: json['periodId'] as String,
  section: json['section'] as String?,
  classroom: json['classroom'] as String?,
  status: $enumDecode(_$EnrollmentStatusEnumMap, json['status']),
  finalGrade: (json['finalGrade'] as num?)?.toDouble(),
  professorId: json['professorId'] as String?,
  subject: json['subject'] == null
      ? null
      : Subject.fromJson(json['subject'] as Map<String, dynamic>),
  period: json['period'] == null
      ? null
      : Period.fromJson(json['period'] as Map<String, dynamic>),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$EnrollmentToJson(Enrollment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'careerId': instance.careerId,
      'subjectId': instance.subjectId,
      'periodId': instance.periodId,
      'section': instance.section,
      'classroom': instance.classroom,
      'status': _$EnrollmentStatusEnumMap[instance.status]!,
      'finalGrade': instance.finalGrade,
      'professorId': instance.professorId,
      'subject': instance.subject,
      'period': instance.period,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$EnrollmentStatusEnumMap = {
  EnrollmentStatus.enrolled: 'ENROLLED',
  EnrollmentStatus.inProgress: 'IN_PROGRESS',
  EnrollmentStatus.passed: 'PASSED',
  EnrollmentStatus.failed: 'FAILED',
  EnrollmentStatus.withdrawn: 'WITHDRAWN',
};
