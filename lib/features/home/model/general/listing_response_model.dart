import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/features/home/model/client/category_response_model.dart';
import 'package:tivi_tea/models/address_model.dart';
import 'package:tivi_tea/models/user_model.dart';

part 'listing_response_model.g.dart';

CategoryResponseModel? _listingCategoryFromJson(Object? json) {
  if (json == null) return null;
  if (json is String) {
    final trimmed = json.trim();
    if (trimmed.isEmpty) return null;
    return CategoryResponseModel(name: trimmed);
  }
  if (json is Map<String, dynamic>) {
    return CategoryResponseModel.fromJson(json);
  }
  return null;
}

Object? _readAmountOrPrice(Map<dynamic, dynamic> json, String key) {
  return json['amount'] ?? json['price'];
}

Object? _readAddressOrPickUp(Map<dynamic, dynamic> json, String key) {
  return json['address'] ?? json['pick_up_address'];
}

Object? _readAvailabilityOrInStock(Map<dynamic, dynamic> json, String key) {
  return json['availability'] ?? json['in_stock'];
}

Object? _readReviewCount(Map<dynamic, dynamic> json, String key) {
  return json['review_count'] ??
      json['reviews_count'] ??
      json['total_reviews'];
}

int? _reviewCountFromJson(Object? json) {
  if (json == null) return null;
  if (json is int) return json;
  if (json is num) return json.toInt();
  return int.tryParse(json.toString());
}

@JsonSerializable(explicitToJson: true)
class ListingResponseModel {
  final String? id;
  @JsonKey(fromJson: _listingCategoryFromJson)
  final CategoryResponseModel? category;
  final List<String>? amenities;
  final List<Room>? rooms;
  final Partner? partner;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  final Map<String, dynamic>? meta;
  final String? name;
  final String? description;
  @JsonKey(name: 'address', readValue: _readAddressOrPickUp)
  final String? address;
  final List<String>? images;
  @JsonKey(name: 'listing_type')
  final String? listingType;
  @JsonKey(name: 'amount', readValue: _readAmountOrPrice)
  final num? amount;
  final User? user;
  final int? quantity;
  final String? condition;
  final String? status;
  @JsonKey(name: 'pricing_option')
  final String? pricingOption;
  @JsonKey(name: 'foot_soldier')
  final bool? footSoldier;
  @JsonKey(name: 'cautionary_fee')
  final num? cautionaryFee;
  @JsonKey(name: 'service_charge')
  final num? serviceFee;
  @JsonKey(name: 'is_favorites')
  final bool? isFavorites;
  @JsonKey(name: 'foot_soldier_amount')
  final num? footSoldierAmount;
  @JsonKey(name: 'amount_plus_foot_soldier_fee')
  final num? amountPlusFootSoldierFee;
  @JsonKey(name: 'availability', readValue: _readAvailabilityOrInStock)
  final bool? availability;
  @JsonKey(
    name: 'review_count',
    readValue: _readReviewCount,
    fromJson: _reviewCountFromJson,
  )
  final int? reviewCount;

  ListingResponseModel({
    this.id,
    this.category,
    this.amenities,
    this.rooms,
    this.partner,
    this.dateCreated,
    this.lastUpdated,
    this.meta,
    this.name,
    this.description,
    this.address,
    this.images,
    this.listingType,
    this.amount,
    this.user,
    this.quantity,
    this.condition,
    this.status,
    this.pricingOption,
    this.footSoldier,
    this.cautionaryFee,
    this.isFavorites,
    this.availability,
    this.reviewCount,
    this.serviceFee,
    this.footSoldierAmount,
    this.amountPlusFootSoldierFee,
  });

  factory ListingResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ListingResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ListingResponseModelToJson(this);

  ListingResponseModel copyWith({
    String? id,
    CategoryResponseModel? category,
    List<String>? amenities,
    List<Room>? rooms,
    Partner? partner,
    DateTime? dateCreated,
    DateTime? lastUpdated,
    Map<String, dynamic>? meta,
    String? name,
    String? description,
    String? address,
    List<String>? images,
    String? listingType,
    num? amount,
    User? user,
    int? quantity,
    String? condition,
    String? status,
    String? pricingOption,
    bool? footSoldier,
    num? cautionaryFee,
    bool? isFavorites,
    bool? availability,
    int? reviewCount,
    num? serviceFee,
    num? footSoldierAmount,
    num? amountPlusFootSoldierFee,
  }) {
    return ListingResponseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amenities: amenities ?? this.amenities,
      rooms: rooms ?? this.rooms,
      partner: partner ?? this.partner,
      dateCreated: dateCreated ?? this.dateCreated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      meta: meta ?? this.meta,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      images: images ?? this.images,
      listingType: listingType ?? this.listingType,
      amount: amount ?? this.amount,
      user: user ?? this.user,
      quantity: quantity ?? this.quantity,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      pricingOption: pricingOption ?? this.pricingOption,
      footSoldier: footSoldier ?? this.footSoldier,
      cautionaryFee: cautionaryFee ?? this.cautionaryFee,
      isFavorites: isFavorites ?? this.isFavorites,
      availability: availability ?? this.availability,
      reviewCount: reviewCount ?? this.reviewCount,
      serviceFee: serviceFee ?? this.serviceFee,
      footSoldierAmount: footSoldierAmount ?? this.footSoldierAmount,
      amountPlusFootSoldierFee:
          amountPlusFootSoldierFee ?? this.amountPlusFootSoldierFee,
    );
  }
}

@JsonSerializable()
class Room {
  final String? id;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @JsonKey(name: 'last_updated')
  final DateTime? lastUpdated;
  final Map<String, dynamic>? meta;
  final String? name;
  final List<String>? images;
  final List<String>? features;
  final bool? availability;
  final String? description;
  @JsonKey(name: 'max_capacity')
  final int? maxCapacity;
  final num? amount;
  final String? listing;

  Room({
    this.id,
    this.dateCreated,
    this.lastUpdated,
    this.meta,
    this.name,
    this.images,
    this.features,
    this.availability,
    this.description,
    this.maxCapacity,
    this.amount,
    this.listing,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Partner {
  final String? id;
  final User? user;
  final Address? address;
  final DateTime? dateCreated;
  final DateTime? lastUpdated;
  final Map<String, dynamic>? meta;
  final String? companyName;
  final String? alternatePhoneNumber;
  final String? businessDescription;
  final String? website;
  final String? businessType;
  final String? footSoldier;

  Partner({
    this.id,
    this.user,
    this.address,
    this.dateCreated,
    this.lastUpdated,
    this.meta,
    this.companyName,
    this.alternatePhoneNumber,
    this.businessDescription,
    this.website,
    this.businessType,
    this.footSoldier,
  });

  factory Partner.fromJson(Map<String, dynamic> json) =>
      _$PartnerFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerToJson(this);
}
