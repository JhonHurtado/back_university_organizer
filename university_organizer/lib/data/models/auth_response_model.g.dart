// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) =>
    AuthResponseModel(
      accessTokenField: json['access_token'] as String,
      refreshTokenField: json['refresh_token'] as String,
      tokenTypeField: json['token_type'] as String,
      expiresInField: (json['expires_in'] as num).toInt(),
      userModel: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'access_token': instance.accessTokenField,
      'refresh_token': instance.refreshTokenField,
      'token_type': instance.tokenTypeField,
      'expires_in': instance.expiresInField,
      'user': instance.userModel,
    };
