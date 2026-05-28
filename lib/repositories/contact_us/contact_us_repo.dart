import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/contact_us/model/contact_us_request_body.dart';

final class ContactUsRepo {
  const ContactUsRepo({required this.restClient});

  final RestClient restClient;

  Future<BaseResponse<dynamic>> contactUs(ContactUsRequestBody body) async {
    try {
      return await restClient.contactUs(body.toJson());
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }
}
