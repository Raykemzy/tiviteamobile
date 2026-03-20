import 'package:json_annotation/json_annotation.dart';
import 'package:tivi_tea/models/enums/enums.dart';

part 'switch_account_request_body.g.dart';

@JsonSerializable()
class SwitchAccountRequestBody {
  const SwitchAccountRequestBody({
    required this.entityType,
  });

  @JsonKey(name: 'entity_type')
  final EntityType entityType;

  factory SwitchAccountRequestBody.fromJson(Map<String, dynamic> json) =>
      _$SwitchAccountRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$SwitchAccountRequestBodyToJson(this);
}
