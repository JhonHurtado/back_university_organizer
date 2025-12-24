import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

/// Schedule type enum
enum ScheduleType {
  @JsonValue('CLASS')
  classType,
  @JsonValue('LAB')
  lab,
  @JsonValue('TUTORIAL')
  tutorial,
  @JsonValue('OFFICE_HOURS')
  officeHours,
  @JsonValue('EXAM')
  exam,
  @JsonValue('OTHER')
  other,
}

/// Schedule model representing a class schedule
@JsonSerializable()
class Schedule {
  final String id;

  @JsonKey(name: 'enrollment_id')
  final String enrollmentId;

  @JsonKey(name: 'day_of_week')
  final int dayOfWeek; // 1 = Monday, 7 = Sunday

  @JsonKey(name: 'start_time')
  final String startTime; // Format: "HH:mm"

  @JsonKey(name: 'end_time')
  final String endTime; // Format: "HH:mm"

  final String? room;
  final String? building;
  final ScheduleType type;
  final String? color;
  final String? notes;

  @JsonKey(name: 'is_recurring')
  final bool isRecurring;

  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.enrollmentId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.building,
    this.type = ScheduleType.classType,
    this.color = '#3B82F6',
    this.notes,
    this.isRecurring = true,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get day name
  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  /// Get short day name
  String get shortDayName {
    switch (dayOfWeek) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'N/A';
    }
  }

  /// Get time range string
  String get timeRange => '$startTime - $endTime';

  /// Get location string
  String get location {
    if (room != null && building != null) {
      return '$room, $building';
    } else if (room != null) {
      return room!;
    } else if (building != null) {
      return building!;
    }
    return 'No location';
  }

  /// Get type display name
  String get typeDisplayName {
    switch (type) {
      case ScheduleType.classType:
        return 'Class';
      case ScheduleType.lab:
        return 'Lab';
      case ScheduleType.tutorial:
        return 'Tutorial';
      case ScheduleType.officeHours:
        return 'Office Hours';
      case ScheduleType.exam:
        return 'Exam';
      case ScheduleType.other:
        return 'Other';
    }
  }

  /// Check if schedule is active on a given date
  bool isActiveOn(DateTime date) {
    if (startDate != null && date.isBefore(startDate!)) return false;
    if (endDate != null && date.isAfter(endDate!)) return false;
    return true;
  }

  /// Calculate duration in minutes
  int get durationMinutes {
    try {
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);
      return end.inMinutes - start.inMinutes;
    } catch (e) {
      return 0;
    }
  }

  Duration _parseTime(String time) {
    final parts = time.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
    );
  }

  /// JSON serialization
  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleToJson(this);

  /// Create copy with modifications
  Schedule copyWith({
    String? id,
    String? enrollmentId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? building,
    ScheduleType? type,
    String? color,
    String? notes,
    bool? isRecurring,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      enrollmentId: enrollmentId ?? this.enrollmentId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      building: building ?? this.building,
      type: type ?? this.type,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
