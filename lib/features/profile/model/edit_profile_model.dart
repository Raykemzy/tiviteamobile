import 'package:json_annotation/json_annotation.dart';

part 'edit_profile_model.g.dart';

@JsonSerializable()
class EditProfileModel {
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  EditProfileModel({
    this.phoneNumber,
    this.profilePicture,
    this.firstName,
    this.lastName,
  });

  factory EditProfileModel.fromJson(Map<String, dynamic> json) =>
      _$EditProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$EditProfileModelToJson(this);
}
