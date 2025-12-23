// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      avatar: json['avatar'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      subscription: json['subscription'] == null
          ? null
          : UserSubscriptionModel.fromJson(
              json['subscription'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'avatar': instance.avatar,
      'emailVerified': instance.emailVerified,
      'subscription': instance.subscription?.toJson(),
    };

UserSubscriptionModel _$UserSubscriptionModelFromJson(
        Map<String, dynamic> json) =>
    UserSubscriptionModel(
      status: json['status'] as String,
      plan: json['plan'] as String,
    );

Map<String, dynamic> _$UserSubscriptionModelToJson(
        UserSubscriptionModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'plan': instance.plan,
    };
