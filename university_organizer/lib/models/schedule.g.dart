// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
  id: json['id'] as String,
  enrollmentId: json['enrollment_id'] as String,
  dayOfWeek: (json['day_of_week'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  room: json['room'] as String?,
  building: json['building'] as String?,
  type:
      $enumDecodeNullable(_$ScheduleTypeEnumMap, json['type']) ??
      ScheduleType.classType,
  color: json['color'] as String? ?? '#3B82F6',
  notes: json['notes'] as String?,
  isRecurring: json['is_recurring'] as bool? ?? true,
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
  'id': instance.id,
  'enrollment_id': instance.enrollmentId,
  'day_of_week': instance.dayOfWeek,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'room': instance.room,
  'building': instance.building,
  'type': _$ScheduleTypeEnumMap[instance.type]!,
  'color': instance.color,
  'notes': instance.notes,
  'is_recurring': instance.isRecurring,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$ScheduleTypeEnumMap = {
  ScheduleType.classType: 'CLASS',
  ScheduleType.lab: 'LAB',
  ScheduleType.tutorial: 'TUTORIAL',
  ScheduleType.officeHours: 'OFFICE_HOURS',
  ScheduleType.exam: 'EXAM',
  ScheduleType.other: 'OTHER',
};
