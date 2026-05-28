import 'package:json_annotation/json_annotation.dart';

part 'contact_us_request_body.g.dart';

@JsonSerializable()
class ContactUsRequestBody {
  const ContactUsRequestBody({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
  });

  final String name;
  final String email;
  final String subject;
  final String message;

  factory ContactUsRequestBody.fromJson(Map<String, dynamic> json) =>
      _$ContactUsRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ContactUsRequestBodyToJson(this);
}
