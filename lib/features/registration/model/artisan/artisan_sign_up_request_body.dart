import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/models/address_model.dart';

part 'artisan_sign_up_request_body.g.dart';

@JsonSerializable()
class ArtisanSignUpRequestBody {
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? password;
  @JsonKey(name: 'confirm_password')
  final String? confirmPassword;
  @JsonKey(name: 'service_type')
  final String? serviceType;
  final String? summary;
  final Address? address;

  ArtisanSignUpRequestBody({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.password,
    this.confirmPassword,
    this.serviceType,
    this.summary,
    this.address,
  });

  factory ArtisanSignUpRequestBody.fromJson(Map<String, dynamic> json) =>
      _$ArtisanSignUpRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ArtisanSignUpRequestBodyToJson(this);
}
