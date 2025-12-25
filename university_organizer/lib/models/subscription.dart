import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

/// Subscription status enum
enum SubscriptionStatus {
  @JsonValue('TRIAL')
  trial,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('PAST_DUE')
  pastDue,
  @JsonValue('EXPIRED')
  expired,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('SUSPENDED')
  suspended,
}

/// Billing period enum
enum BillingPeriod {
  @JsonValue('MONTHLY')
  monthly,
  @JsonValue('QUARTERLY')
  quarterly,
  @JsonValue('SEMI_ANNUAL')
  semiAnnual,
  @JsonValue('ANNUAL')
  annual,
  @JsonValue('LIFETIME')
  lifetime,
}

/// Plan model
@JsonSerializable()
class Plan {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final String currency;

  @JsonKey(name: 'billing_period')
  final BillingPeriod billingPeriod;

  @JsonKey(name: 'trial_days')
  final int trialDays;

  @JsonKey(name: 'max_careers')
  final int maxCareers;

  @JsonKey(name: 'max_subjects_per_career')
  final int maxSubjectsPerCareer;

  @JsonKey(name: 'can_export_pdf')
  final bool canExportPDF;

  @JsonKey(name: 'can_export_excel')
  final bool canExportExcel;

  @JsonKey(name: 'has_analytics')
  final bool hasAnalytics;

  @JsonKey(name: 'is_popular')
  final bool isPopular;

  Plan({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.currency = 'USD',
    this.billingPeriod = BillingPeriod.monthly,
    this.trialDays = 0,
    this.maxCareers = 1,
    this.maxSubjectsPerCareer = 50,
    this.canExportPDF = false,
    this.canExportExcel = false,
    this.hasAnalytics = false,
    this.isPopular = false,
  });

  /// Get billing period display name
  String get billingPeriodDisplayName {
    switch (billingPeriod) {
      case BillingPeriod.monthly:
        return 'Monthly';
      case BillingPeriod.quarterly:
        return 'Quarterly';
      case BillingPeriod.semiAnnual:
        return 'Semi-Annual';
      case BillingPeriod.annual:
        return 'Annual';
      case BillingPeriod.lifetime:
        return 'Lifetime';
    }
  }

  /// Get price display
  String get priceDisplay => '\$$price';

  /// JSON serialization
  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
  Map<String, dynamic> toJson() => _$PlanToJson(this);
}

/// Subscription model
@JsonSerializable()
class Subscription {
  final String? id;

  @JsonKey(name: 'user_id')
  final String? userId;

  @JsonKey(name: 'plan_id')
  final String? planId;

  final SubscriptionStatus? status;

  @JsonKey(name: 'start_date')
  final DateTime? startDate;

  @JsonKey(name: 'end_date')
  final DateTime? endDate;

  @JsonKey(name: 'trial_ends_at')
  final DateTime? trialEndsAt;

  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;

  @JsonKey(name: 'auto_renew')
  final bool? autoRenew;

  @JsonKey(name: 'next_billing_date')
  final DateTime? nextBillingDate;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Relation - can be either Plan object or String (plan name)
  final dynamic plan;

  Subscription({
    this.id,
    this.userId,
    this.planId,
    this.status,
    this.startDate,
    this.endDate,
    this.trialEndsAt,
    this.cancelledAt,
    this.autoRenew,
    this.nextBillingDate,
    this.createdAt,
    this.updatedAt,
    this.plan,
  });

  /// Check if subscription is active
  bool get isActive => status == SubscriptionStatus.active;

  /// Check if subscription is in trial
  bool get isTrial => status == SubscriptionStatus.trial;

  /// Check if subscription is expired
  bool get isExpired =>
      status == SubscriptionStatus.expired ||
      status == SubscriptionStatus.cancelled;

  /// Get days remaining
  int get daysRemaining {
    if (endDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  /// Check if trial is active
  bool get isTrialActive {
    if (trialEndsAt == null) return false;
    return DateTime.now().isBefore(trialEndsAt!);
  }

  /// Get plan name
  String get planName {
    if (plan == null) return 'Free';
    if (plan is String) return plan as String;
    if (plan is Plan) return (plan as Plan).name;
    return 'Unknown';
  }

  /// Get status display name
  String get statusDisplayName {
    if (status == null) return 'Unknown';
    switch (status!) {
      case SubscriptionStatus.trial:
        return 'Trial';
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.pastDue:
        return 'Past Due';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.suspended:
        return 'Suspended';
    }
  }

  /// Get status color
  String get statusColor {
    if (status == null) return '#9CA3AF'; // Gray
    switch (status!) {
      case SubscriptionStatus.trial:
      case SubscriptionStatus.active:
        return '#10B981'; // Green
      case SubscriptionStatus.pastDue:
        return '#F59E0B'; // Orange
      case SubscriptionStatus.expired:
      case SubscriptionStatus.cancelled:
      case SubscriptionStatus.suspended:
        return '#EF4444'; // Red
    }
  }

  /// JSON serialization
  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);

  /// Create copy with modifications
  Subscription copyWith({
    String? id,
    String? userId,
    String? planId,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndsAt,
    DateTime? cancelledAt,
    bool? autoRenew,
    DateTime? nextBillingDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic plan,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      autoRenew: autoRenew ?? this.autoRenew,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plan: plan ?? this.plan,
    );
  }
}
