import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/models/enums/enums.dart';

part 'login_request_object.g.dart';

@JsonSerializable(includeIfNull: false)
class LoginRequestObject {
  final String? email;
  final String? password;

  /// Which entity to sign in as. Only sent on the retry after the backend
  /// reports that the account has several entities — a first attempt omits it
  /// so single-entity accounts log in in one round trip.
  @JsonKey(name: 'entity_type')
  final EntityType? entityType;

  LoginRequestObject({
    this.email,
    this.password,
    this.entityType,
  });

  LoginRequestObject withEntityType(EntityType value) => LoginRequestObject(
        email: email,
        password: password,
        entityType: value,
      );

  factory LoginRequestObject.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestObjectFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestObjectToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequestObject {
  final String? email;

  ForgotPasswordRequestObject({
    this.email,
  });

  factory ForgotPasswordRequestObject.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestObjectFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordRequestObjectToJson(this);
}
