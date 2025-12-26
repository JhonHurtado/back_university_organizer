import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'period.g.dart';

/// Academic Period model
@JsonSerializable()
class Period extends Equatable {
  final String id;
  final String careerId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool? isCurrent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Period({
    required this.id,
    required this.careerId,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isCurrent,
    this.createdAt,
    this.updatedAt,
  });

  factory Period.fromJson(Map<String, dynamic> json) => _$PeriodFromJson(json);

  Map<String, dynamic> toJson() => _$PeriodToJson(this);

  Period copyWith({
    String? id,
    String? careerId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Period(
      id: id ?? this.id,
      careerId: careerId ?? this.careerId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if period is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  @override
  List<Object?> get props => [
        id,
        careerId,
        name,
        startDate,
        endDate,
        isCurrent,
        createdAt,
        updatedAt,
      ];
}
