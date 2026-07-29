// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String?,
      entityType:
          $enumDecodeNullable(_$EntityTypeEnumMap, json['entity_type']) ??
              EntityType.client,
      availableEntityTypes: json['available_entity_types'] == null
          ? const []
          : _availableEntityTypesFromJson(json['available_entity_types']),
      lastLogin: json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
      isSuperuser: json['is_superuser'] as bool?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      isVerified: json['is_verified'] as bool?,
      isStaff: json['is_staff'] as bool?,
      isActive: json['is_active'] as bool?,
      kycIsVerified: json['kyc_is_verified'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      profilePicture: json['profile_picture'] as String?,
      hasUploadedKycDocuments: json['has_uploaded_kyc_documents'] as bool?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      groups: json['groups'] as List<dynamic>? ?? const [],
      userPermissions: json['user_permissions'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'entity_type': _$EntityTypeEnumMap[instance.entityType],
      'available_entity_types':
          _availableEntityTypesToJson(instance.availableEntityTypes),
      'last_login': instance.lastLogin?.toIso8601String(),
      'is_superuser': instance.isSuperuser,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'is_verified': instance.isVerified,
      'is_staff': instance.isStaff,
      'is_active': instance.isActive,
      'kyc_is_verified': instance.kycIsVerified,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'profile_picture': instance.profilePicture,
      'has_uploaded_kyc_documents': instance.hasUploadedKycDocuments,
      'address': instance.address,
      'groups': instance.groups,
      'user_permissions': instance.userPermissions,
    };

const _$EntityTypeEnumMap = {
  EntityType.partner: 'partner',
  EntityType.client: 'client',
  EntityType.artisan: 'artisan',
};

GetUserProfileResponse _$GetUserProfileResponseFromJson(
        Map<String, dynamic> json) =>
    GetUserProfileResponse(
      id: json['id'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetUserProfileResponseToJson(
        GetUserProfileResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'address': instance.address,
    };

UploadProfilePicResponse _$UploadProfilePicResponseFromJson(
        Map<String, dynamic> json) =>
    UploadProfilePicResponse(
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$UploadProfilePicResponseToJson(
        UploadProfilePicResponse instance) =>
    <String, dynamic>{
      'image_url': instance.imageUrl,
    };
