// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditProfileModel _$EditProfileModelFromJson(Map<String, dynamic> json) =>
    EditProfileModel(
      phoneNumber: json['phone_number'] as String?,
      profilePicture: json['profile_picture'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      artisanGalleryImages: (json['artisan_gallery_images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$EditProfileModelToJson(EditProfileModel instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'profile_picture': instance.profilePicture,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      if (instance.artisanGalleryImages case final value?)
        'artisan_gallery_images': value,
    };
