import 'package:json_annotation/json_annotation.dart';

part 'request_quotation_request_body.g.dart';

@JsonSerializable()
class RequestQuotationRequestBody {
  const RequestQuotationRequestBody({
    required this.clientNote,
    required this.images,
    required this.clientEndDate,
  });

  @JsonKey(name: 'client_note')
  final String clientNote;
  final List<String> images;
  @JsonKey(name: 'client_end_date')
  final String clientEndDate;

  factory RequestQuotationRequestBody.fromJson(Map<String, dynamic> json) =>
      _$RequestQuotationRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$RequestQuotationRequestBodyToJson(this);
}
