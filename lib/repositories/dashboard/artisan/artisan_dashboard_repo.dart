import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/home/model/artisan/artisan_dashboard_model.dart';

final class ArtisanDashBoardRepo {
  final RestClient restClient;

  ArtisanDashBoardRepo({required this.restClient});

  Future<BaseResponse<ArtisanDashboardModel>> getArtisanDashboard() async {
    try {
      return await restClient.getArtisanDashboard();
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }
}
