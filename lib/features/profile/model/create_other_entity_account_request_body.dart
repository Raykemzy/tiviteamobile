import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/models/address_model.dart';
import 'package:tivi_tea/models/enums/enums.dart';

part 'create_other_entity_account_request_body.g.dart';

/// Body for `POST /authentication/user/create-other-entity-account`.
///
/// The endpoint takes a different shape per entity:
/// * **artisan** — `service_type` + `summary`
/// * **partner** — `company_name`, `business_type`, `business_description`,
///   `website`, `alternate_phone_number`
/// * **client** — address only
///
/// Fields outside the target entity's shape are omitted rather than sent
/// empty, so use the named constructors instead of building this directly.
@JsonSerializable(includeIfNull: false)
class CreateOtherEntityAccountRequestBody {
  const CreateOtherEntityAccountRequestBody({
    required this.entityType,
    required this.address,
    this.serviceType,
    this.summary,
    this.companyName,
    this.businessType,
    this.businessDescription,
    this.website,
    this.alternatePhoneNumber,
  });

  /// Artisan entity: service type and an optional short summary.
  factory CreateOtherEntityAccountRequestBody.artisan({
    required Address address,
    required String serviceType,
    String summary = '',
  }) =>
      CreateOtherEntityAccountRequestBody(
        entityType: EntityType.artisan,
        address: address,
        serviceType: serviceType,
        summary: summary,
      );

  /// Partner entity. `website` and `alternatePhoneNumber` are sent as empty
  /// strings when blank — the backend expects the keys present.
  factory CreateOtherEntityAccountRequestBody.partner({
    required Address address,
    required String companyName,
    required String businessType,
    required String businessDescription,
    String website = '',
    String alternatePhoneNumber = '',
  }) =>
      CreateOtherEntityAccountRequestBody(
        entityType: EntityType.partner,
        address: address,
        companyName: companyName,
        businessType: businessType,
        businessDescription: businessDescription,
        website: website,
        alternatePhoneNumber: alternatePhoneNumber,
      );

  /// Client entity — nothing beyond the address is required.
  factory CreateOtherEntityAccountRequestBody.client({
    required Address address,
  }) =>
      CreateOtherEntityAccountRequestBody(
        entityType: EntityType.client,
        address: address,
      );

  @JsonKey(name: 'entity_type')
  final EntityType entityType;
  final Address address;

  @JsonKey(name: 'service_type')
  final String? serviceType;
  final String? summary;

  @JsonKey(name: 'company_name')
  final String? companyName;
  @JsonKey(name: 'business_type')
  final String? businessType;
  @JsonKey(name: 'business_description')
  final String? businessDescription;
  final String? website;
  @JsonKey(name: 'alternate_phone_number')
  final String? alternatePhoneNumber;

  factory CreateOtherEntityAccountRequestBody.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$CreateOtherEntityAccountRequestBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateOtherEntityAccountRequestBodyToJson(this);
}
