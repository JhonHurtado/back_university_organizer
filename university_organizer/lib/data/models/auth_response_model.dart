import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/auth_response.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel extends AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessTokenField;

  @JsonKey(name: 'refresh_token')
  final String refreshTokenField;

  @JsonKey(name: 'token_type')
  final String tokenTypeField;

  @JsonKey(name: 'expires_in')
  final int expiresInField;

  @JsonKey(name: 'user')
  final UserModel userModel;

  const AuthResponseModel({
    required this.accessTokenField,
    required this.refreshTokenField,
    required this.tokenTypeField,
    required this.expiresInField,
    required this.userModel,
  }) : super(
          accessToken: accessTokenField,
          refreshToken: refreshTokenField,
          tokenType: tokenTypeField,
          expiresIn: expiresInField,
          user: userModel,
        );

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  AuthResponse toEntity() {
    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      user: userModel.toEntity(),
    );
  }
}
