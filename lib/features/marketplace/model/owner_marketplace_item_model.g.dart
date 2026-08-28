// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_marketplace_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnerMarketplaceItemModel _$OwnerMarketplaceItemModelFromJson(
        Map<String, dynamic> json) =>
    OwnerMarketplaceItemModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      user: json['user'] == null
          ? null
          : OwnerMarketplaceItemUser.fromJson(
              json['user'] as Map<String, dynamic>),
      price: json['price'] as num?,
      inStock: json['in_stock'] as bool?,
      quantity: (json['quantity'] as num?)?.toInt(),
      category: json['category'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$OwnerMarketplaceItemModelToJson(
        OwnerMarketplaceItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'images': instance.images,
      'user': instance.user?.toJson(),
      'price': instance.price,
      'in_stock': instance.inStock,
      'quantity': instance.quantity,
      'category': instance.category,
      'status': instance.status,
    };

OwnerMarketplaceItemUser _$OwnerMarketplaceItemUserFromJson(
        Map<String, dynamic> json) =>
    OwnerMarketplaceItemUser(
      id: json['id'] as String?,
      entityType: json['entity_type'] as String?,
      signedInEntityType: json['signed_in_entity_type'] as String?,
      availableEntityTypes: (json['available_entity_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
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
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      profilePicture: json['profile_picture'] as String?,
      isDeactivated: json['is_deactivated'] as bool?,
      isTest: json['is_test'] as bool?,
      meta: json['meta'] as Map<String, dynamic>?,
      groups: json['groups'] as List<dynamic>?,
      userPermissions: json['user_permissions'] as List<dynamic>?,
    );

Map<String, dynamic> _$OwnerMarketplaceItemUserToJson(
        OwnerMarketplaceItemUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entity_type': instance.entityType,
      'signed_in_entity_type': instance.signedInEntityType,
      'available_entity_types': instance.availableEntityTypes,
      'last_login': instance.lastLogin?.toIso8601String(),
      'is_superuser': instance.isSuperuser,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'is_verified': instance.isVerified,
      'is_staff': instance.isStaff,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'profile_picture': instance.profilePicture,
      'is_deactivated': instance.isDeactivated,
      'is_test': instance.isTest,
      'meta': instance.meta,
      'groups': instance.groups,
      'user_permissions': instance.userPermissions,
    };
