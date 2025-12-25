// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plan _$PlanFromJson(Map<String, dynamic> json) => Plan(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  billingPeriod:
      $enumDecodeNullable(_$BillingPeriodEnumMap, json['billing_period']) ??
      BillingPeriod.monthly,
  trialDays: (json['trial_days'] as num?)?.toInt() ?? 0,
  maxCareers: (json['max_careers'] as num?)?.toInt() ?? 1,
  maxSubjectsPerCareer:
      (json['max_subjects_per_career'] as num?)?.toInt() ?? 50,
  canExportPDF: json['can_export_pdf'] as bool? ?? false,
  canExportExcel: json['can_export_excel'] as bool? ?? false,
  hasAnalytics: json['has_analytics'] as bool? ?? false,
  isPopular: json['is_popular'] as bool? ?? false,
);

Map<String, dynamic> _$PlanToJson(Plan instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'price': instance.price,
  'currency': instance.currency,
  'billing_period': _$BillingPeriodEnumMap[instance.billingPeriod]!,
  'trial_days': instance.trialDays,
  'max_careers': instance.maxCareers,
  'max_subjects_per_career': instance.maxSubjectsPerCareer,
  'can_export_pdf': instance.canExportPDF,
  'can_export_excel': instance.canExportExcel,
  'has_analytics': instance.hasAnalytics,
  'is_popular': instance.isPopular,
};

const _$BillingPeriodEnumMap = {
  BillingPeriod.monthly: 'MONTHLY',
  BillingPeriod.quarterly: 'QUARTERLY',
  BillingPeriod.semiAnnual: 'SEMI_ANNUAL',
  BillingPeriod.annual: 'ANNUAL',
  BillingPeriod.lifetime: 'LIFETIME',
};

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) => Subscription(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  planId: json['plan_id'] as String?,
  status: $enumDecodeNullable(_$SubscriptionStatusEnumMap, json['status']),
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  trialEndsAt: json['trial_ends_at'] == null
      ? null
      : DateTime.parse(json['trial_ends_at'] as String),
  cancelledAt: json['cancelled_at'] == null
      ? null
      : DateTime.parse(json['cancelled_at'] as String),
  autoRenew: json['auto_renew'] as bool?,
  nextBillingDate: json['next_billing_date'] == null
      ? null
      : DateTime.parse(json['next_billing_date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  plan: json['plan'],
);

Map<String, dynamic> _$SubscriptionToJson(Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'plan_id': instance.planId,
      'status': _$SubscriptionStatusEnumMap[instance.status],
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'trial_ends_at': instance.trialEndsAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'auto_renew': instance.autoRenew,
      'next_billing_date': instance.nextBillingDate?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'plan': instance.plan,
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.trial: 'TRIAL',
  SubscriptionStatus.active: 'ACTIVE',
  SubscriptionStatus.pastDue: 'PAST_DUE',
  SubscriptionStatus.expired: 'EXPIRED',
  SubscriptionStatus.cancelled: 'CANCELLED',
  SubscriptionStatus.suspended: 'SUSPENDED',
};
