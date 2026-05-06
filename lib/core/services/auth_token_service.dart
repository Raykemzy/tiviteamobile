import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tivi_tea/core/config/dio_config.dart';

class AuthTokenService {
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await Dio().post<Map<String, dynamic>>(
      '${BaseEnv.baseUrl}/user/token/refresh',
      data: {'refresh': refreshToken},
      options: Options(
        headers: const {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
      ),
    );

    final responseData = response.data;
    if (response.statusCode == 200 && responseData != null) {
      return responseData;
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      error: 'Token refresh failed',
      type: DioExceptionType.badResponse,
    );
  }
}

final authTokenServiceProvider = Provider<AuthTokenService>((ref) {
  return AuthTokenService();
});
