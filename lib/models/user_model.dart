import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/models/address_model.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/repositories/enums.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String? id;
  @JsonKey(name: 'entity_type', defaultValue: EntityType.client)
  final EntityType? entityType;

  /// Entities this user actually owns. Parsed leniently because the backend
  /// occasionally returns unrecognised strings (e.g. "multiple accounts
  /// found"); unknown values are dropped rather than throwing.
  ///
  /// Serialised back out so the list survives being cached in Hive — the
  /// account switcher reads it on cold start, before any network call.
  @JsonKey(
    name: 'available_entity_types',
    fromJson: _availableEntityTypesFromJson,
    toJson: _availableEntityTypesToJson,
  )
  final List<EntityType> availableEntityTypes;
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;
  @JsonKey(name: 'is_superuser')
  final bool? isSuperuser;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'is_verified')
  final bool? isVerified;
  @JsonKey(name: 'is_staff')
  final bool? isStaff;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'kyc_is_verified', includeFromJson: true)
  final bool? kycIsVerified;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'has_uploaded_kyc_documents')
  final bool? hasUploadedKycDocuments;

  /// The signed-in entity's address. The backend returns this alongside the
  /// user rather than inside it, so it is populated by the login/profile
  /// repositories rather than parsed straight off the user payload. Cached so
  /// the create-entity form can prefill it.
  final Address? address;
  final List<dynamic>? groups;
  @JsonKey(name: 'user_permissions')
  final List<dynamic>? userPermissions;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final KYCVerificationStatus? kycVerificationStatus;

  User({
    this.id,
    this.entityType,
    this.availableEntityTypes = const [],
    this.lastLogin,
    this.isSuperuser,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.isVerified,
    this.isStaff,
    this.isActive,
    this.kycIsVerified,
    this.createdAt,
    this.updatedAt,
    this.profilePicture,
    this.hasUploadedKycDocuments,
    this.address,
    this.groups = const [],
    this.userPermissions = const [],
    this.kycVerificationStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    EntityType? entityType,
    List<EntityType>? availableEntityTypes,
    DateTime? lastLogin,
    bool? isSuperuser,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    bool? isVerified,
    bool? isStaff,
    bool? isActive,
    bool? kycIsVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profilePicture,
    bool? hasUploadedKycDocuments,
    Address? address,
    List<String>? groups,
    List<String>? userPermissions,
    KYCVerificationStatus? kycVerificationStatus,
  }) {
    return User(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      availableEntityTypes: availableEntityTypes ?? this.availableEntityTypes,
      lastLogin: lastLogin ?? this.lastLogin,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      isStaff: isStaff ?? this.isStaff,
      isActive: isActive ?? this.isActive,
      kycIsVerified: kycIsVerified ?? this.kycIsVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profilePicture: profilePicture ?? this.profilePicture,
      hasUploadedKycDocuments:
          hasUploadedKycDocuments ?? this.hasUploadedKycDocuments,
      address: address ?? this.address,
      groups: groups ?? this.groups,
      userPermissions: userPermissions ?? this.userPermissions,
      kycVerificationStatus:
          kycVerificationStatus ?? this.kycVerificationStatus,
    );
  }
}

List<EntityType> _availableEntityTypesFromJson(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((e) => _entityTypeFromString(e?.toString()))
      .whereType<EntityType>()
      .toList();
}

List<String> _availableEntityTypesToJson(List<EntityType> value) =>
    value.map((e) => e.name).toList();

EntityType? _entityTypeFromString(String? value) {
  switch (value) {
    case 'partner':
      return EntityType.partner;
    case 'client':
      return EntityType.client;
    case 'artisan':
      return EntityType.artisan;
    default:
      return null;
  }
}

extension EntityTypeLabel on EntityType {
  String get label {
    switch (this) {
      case EntityType.partner:
        return 'Partner';
      case EntityType.client:
        return 'Client';
      case EntityType.artisan:
        return 'Artisan';
    }
  }
}

@JsonSerializable()
class GetUserProfileResponse {
  final String? id;
  final User? user;

  /// Sits beside the user in the envelope, mirroring the login response.
  /// Null when this endpoint doesn't include it.
  final Address? address;

  GetUserProfileResponse({
    this.id,
    this.user,
    this.address,
  });

  factory GetUserProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$GetUserProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GetUserProfileResponseToJson(this);
}

@JsonSerializable()
class UploadProfilePicResponse {
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  UploadProfilePicResponse({this.imageUrl});

  factory UploadProfilePicResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadProfilePicResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadProfilePicResponseToJson(this);
}
