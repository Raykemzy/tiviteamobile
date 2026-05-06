import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/models/address_model.dart';
import 'package:tivi_tea/models/enums/enums.dart';

part 'create_other_entity_account_request_body.g.dart';

@JsonSerializable()
class CreateOtherEntityAccountRequestBody {
  const CreateOtherEntityAccountRequestBody({
    required this.entityType,
    required this.serviceType,
    required this.address,
    required this.summary,
  });

  @JsonKey(name: 'entity_type')
  final EntityType entityType;
  @JsonKey(name: 'service_type')
  final String serviceType;
  final Address address;
  final String summary;

  factory CreateOtherEntityAccountRequestBody.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$CreateOtherEntityAccountRequestBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateOtherEntityAccountRequestBodyToJson(this);
}
