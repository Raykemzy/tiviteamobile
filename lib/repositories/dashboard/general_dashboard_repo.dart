import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tivi_tea/core/config/exceptions/app_exception.dart';
import 'package:tivi_tea/core/response/base_response.dart';
import 'package:tivi_tea/core/services/rest_client/rest_client.dart';
import 'package:tivi_tea/features/profile/model/create_other_entity_account_request_body.dart';
import 'package:tivi_tea/features/profile/model/edit_profile_model.dart';
import 'package:tivi_tea/features/profile/model/switch_account_request_body.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/models/user_model.dart';
import 'package:tivi_tea/repositories/user/user_repo.dart';

final class GeneralDashboardRepo {
  final RestClient restClient;
  final UserRepository userRepository;

  GeneralDashboardRepo({
    required this.restClient,
    required this.userRepository,
  });

  Future<BaseResponse<GetUserProfileResponse>> getUserProfile() async {
    try {
      final cachedUser = userRepository.getUser();
      final result = await restClient.getUserProfile();
      final userLoginData = result.data?.user;

      //This was done this way for a reason at the time, and can't remember.
      //TODO: Revisit

      userRepository.saveUser(
        userLoginData?.copyWith(
          kycIsVerified: userLoginData.kycIsVerified,
          profilePicture: userLoginData.profilePicture,
          // This payload doesn't always carry the address or the owned-entity
          // list. copyWith keeps the cached value when the new one is
          // null/empty, so refreshing never silently drops either.
          address: result.data?.address ?? cachedUser.address,
          availableEntityTypes: userLoginData.availableEntityTypes.isEmpty
              ? cachedUser.availableEntityTypes
              : userLoginData.availableEntityTypes,
        ),
      );
      return result;
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<User>> updateUserProfile(EditProfileModel data) async {
    try {
      final result = await restClient.updateUserProfile(data);
      final userLoginData = result.data;

      userRepository.saveUser(userLoginData);

      return result;
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> switchAccount(EntityType entityType) async {
    try {
      return await restClient.switchAccount(
        SwitchAccountRequestBody(entityType: entityType),
      );
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<dynamic>> createOtherEntityAccount(
    CreateOtherEntityAccountRequestBody data,
  ) async {
    try {
      return await restClient.createOtherEntityAccount(data);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }

  Future<BaseResponse<UploadProfilePicResponse>> uploadProfilePic({
    required File image,
  }) async {
    try {
      final result = await restClient.uploadProfilePic(image: image);
      final user = userRepository.getUser();
      final userWithProfilePic = user.copyWith(profilePicture: result.imageUrl);

      await userRepository.saveUser(userWithProfilePic);

      return BaseResponse(status: 'Success', data: result);
    } on DioException catch (e) {
      return AppException.handleError(e);
    }
  }
}
