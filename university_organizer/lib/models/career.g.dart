// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'career.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Career _$CareerFromJson(Map<String, dynamic> json) => Career(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  code: json['code'] as String?,
  university: json['university'] as String,
  faculty: json['faculty'] as String?,
  campus: json['campus'] as String?,
  totalCredits: (json['total_credits'] as num).toInt(),
  totalSemesters: (json['total_semesters'] as num).toInt(),
  currentSemester: (json['current_semester'] as num?)?.toInt() ?? 1,
  gradeScale:
      $enumDecodeNullable(_$GradeScaleEnumMap, json['grade_scale']) ??
      GradeScale.five,
  minPassingGrade: (json['min_passing_grade'] as num?)?.toDouble() ?? 3.0,
  maxGrade: (json['max_grade'] as num?)?.toDouble() ?? 5.0,
  startDate: DateTime.parse(json['start_date'] as String),
  expectedEndDate: json['expected_end_date'] == null
      ? null
      : DateTime.parse(json['expected_end_date'] as String),
  actualEndDate: json['actual_end_date'] == null
      ? null
      : DateTime.parse(json['actual_end_date'] as String),
  status:
      $enumDecodeNullable(_$CareerStatusEnumMap, json['status']) ??
      CareerStatus.active,
  color: json['color'] as String? ?? '#3B82F6',
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
);

Map<String, dynamic> _$CareerToJson(Career instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'code': instance.code,
  'university': instance.university,
  'faculty': instance.faculty,
  'campus': instance.campus,
  'total_credits': instance.totalCredits,
  'total_semesters': instance.totalSemesters,
  'current_semester': instance.currentSemester,
  'grade_scale': _$GradeScaleEnumMap[instance.gradeScale]!,
  'min_passing_grade': instance.minPassingGrade,
  'max_grade': instance.maxGrade,
  'start_date': instance.startDate.toIso8601String(),
  'expected_end_date': instance.expectedEndDate?.toIso8601String(),
  'actual_end_date': instance.actualEndDate?.toIso8601String(),
  'status': _$CareerStatusEnumMap[instance.status]!,
  'color': instance.color,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
};

const _$GradeScaleEnumMap = {
  GradeScale.five: 'FIVE',
  GradeScale.ten: 'TEN',
  GradeScale.hundred: 'HUNDRED',
  GradeScale.fourGPA: 'FOUR_GPA',
  GradeScale.seven: 'SEVEN',
};

const _$CareerStatusEnumMap = {
  CareerStatus.active: 'ACTIVE',
  CareerStatus.completed: 'COMPLETED',
  CareerStatus.paused: 'PAUSED',
  CareerStatus.cancelled: 'CANCELLED',
  CareerStatus.graduated: 'GRADUATED',
};
