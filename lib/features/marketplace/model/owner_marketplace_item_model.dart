import 'package:json_annotation/json_annotation.dart';

part 'owner_marketplace_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OwnerMarketplaceItemModel {
  const OwnerMarketplaceItemModel({
    this.id,
    this.name,
    this.description,
    this.images,
    this.user,
    this.price,
    this.inStock,
    this.quantity,
    this.category,
    this.status,
  });

  final String? id;
  final String? name;
  final String? description;
  final List<String>? images;
  final OwnerMarketplaceItemUser? user;
  final num? price;
  @JsonKey(name: 'in_stock')
  final bool? inStock;
  final int? quantity;
  final String? category;

  /// "Published" or "Draft". Items are created as drafts and stay invisible in
  /// the marketplace until published, which is why sellers reported adding an
  /// item and never seeing it listed.
  final String? status;

  bool get isPublished => status?.toLowerCase() == 'published';

  factory OwnerMarketplaceItemModel.fromJson(Map<String, dynamic> json) =>
      _$OwnerMarketplaceItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerMarketplaceItemModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OwnerMarketplaceItemUser {
  const OwnerMarketplaceItemUser({
    this.id,
    this.entityType,
    this.signedInEntityType,
    this.availableEntityTypes,
    this.lastLogin,
    this.isSuperuser,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.isVerified,
    this.isStaff,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.profilePicture,
    this.isDeactivated,
    this.isTest,
    this.meta,
    this.groups,
    this.userPermissions,
  });

  final String? id;
  @JsonKey(name: 'entity_type')
  final String? entityType;
  @JsonKey(name: 'signed_in_entity_type')
  final String? signedInEntityType;
  @JsonKey(name: 'available_entity_types')
  final List<String>? availableEntityTypes;
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
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'is_deactivated')
  final bool? isDeactivated;
  @JsonKey(name: 'is_test')
  final bool? isTest;
  final Map<String, dynamic>? meta;
  final List<dynamic>? groups;
  @JsonKey(name: 'user_permissions')
  final List<dynamic>? userPermissions;

  factory OwnerMarketplaceItemUser.fromJson(Map<String, dynamic> json) =>
      _$OwnerMarketplaceItemUserFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerMarketplaceItemUserToJson(this);
}
