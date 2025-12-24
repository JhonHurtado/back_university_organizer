// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grade _$GradeFromJson(Map<String, dynamic> json) => Grade(
  id: json['id'] as String,
  enrollmentId: json['enrollment_id'] as String,
  cutNumber: (json['cut_number'] as num).toInt(),
  cutName: json['cut_name'] as String?,
  weight: (json['weight'] as num).toDouble(),
  grade: (json['grade'] as num).toDouble(),
  maxGrade: (json['max_grade'] as num?)?.toDouble() ?? 5.0,
  weightedGrade: (json['weighted_grade'] as num?)?.toDouble(),
  description: json['description'] as String?,
  notes: json['notes'] as String?,
  gradedAt: DateTime.parse(json['graded_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GradeToJson(Grade instance) => <String, dynamic>{
  'id': instance.id,
  'enrollment_id': instance.enrollmentId,
  'cut_number': instance.cutNumber,
  'cut_name': instance.cutName,
  'weight': instance.weight,
  'grade': instance.grade,
  'max_grade': instance.maxGrade,
  'weighted_grade': instance.weightedGrade,
  'description': instance.description,
  'notes': instance.notes,
  'graded_at': instance.gradedAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

GradeItem _$GradeItemFromJson(Map<String, dynamic> json) => GradeItem(
  id: json['id'] as String,
  gradeId: json['grade_id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$GradeItemTypeEnumMap, json['type']),
  weight: (json['weight'] as num).toDouble(),
  grade: (json['grade'] as num).toDouble(),
  maxGrade: (json['max_grade'] as num?)?.toDouble() ?? 5.0,
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GradeItemToJson(GradeItem instance) => <String, dynamic>{
  'id': instance.id,
  'grade_id': instance.gradeId,
  'name': instance.name,
  'type': _$GradeItemTypeEnumMap[instance.type]!,
  'weight': instance.weight,
  'grade': instance.grade,
  'max_grade': instance.maxGrade,
  'due_date': instance.dueDate?.toIso8601String(),
  'submitted_at': instance.submittedAt?.toIso8601String(),
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$GradeItemTypeEnumMap = {
  GradeItemType.exam: 'EXAM',
  GradeItemType.quiz: 'QUIZ',
  GradeItemType.assignment: 'ASSIGNMENT',
  GradeItemType.project: 'PROJECT',
  GradeItemType.lab: 'LAB',
  GradeItemType.presentation: 'PRESENTATION',
  GradeItemType.participation: 'PARTICIPATION',
  GradeItemType.other: 'OTHER',
};
