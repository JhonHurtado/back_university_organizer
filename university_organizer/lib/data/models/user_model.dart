import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel extends User {
  @override
  @JsonKey(name: 'subscription')
  final UserSubscriptionModel? subscription;

  const UserModel({
    required String id,
    required String email,
    required String fullName,
    String? avatar,
    bool emailVerified = false,
    this.subscription,
  }) : super(
          id: id,
          email: email,
          fullName: fullName,
          avatar: avatar,
          emailVerified: emailVerified,
          subscription: subscription,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      avatar: user.avatar,
      emailVerified: user.emailVerified,
      subscription: user.subscription != null
          ? UserSubscriptionModel(
              status: user.subscription!.status,
              plan: user.subscription!.plan,
            )
          : null,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      fullName: fullName,
      avatar: avatar,
      emailVerified: emailVerified,
      subscription: subscription,
    );
  }
}

@JsonSerializable()
class UserSubscriptionModel extends UserSubscription {
  const UserSubscriptionModel({
    required super.status,
    required super.plan,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$UserSubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserSubscriptionModelToJson(this);
}
