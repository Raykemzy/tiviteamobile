import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/services/third_party_services/cloudinary_service.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/utils/logger.dart';
import 'package:tivi_tea/features/artisans/model/quotation_model.dart';
import 'package:tivi_tea/features/artisans/model/request_quotation_request_body.dart';
import 'package:tivi_tea/features/artisans/view_model/artisans_state.dart';
import 'package:tivi_tea/repositories/artisans/artisans_repo.dart';

part 'artisans_notifier.g.dart';

@riverpod
class ArtisansNotifier extends _$ArtisansNotifier {
  late final ArtisansRepo _repo;
  late final CloudinaryService _cloudinaryService;

  @override
  ArtisansState build() {
    const String cloudName = 'tivitea';
    const String uploadPreset = 'hobmtu4o';
    _repo = ArtisansRepo(restClient: ref.read(restClient));
    _cloudinaryService = CloudinaryService(
      cloudinary: CloudinaryPublic(cloudName, uploadPreset),
    );
    return ArtisansState.initial();
  }

  Future<void> getArtisansList({int page = 1, bool loadMore = false}) async {
    if (loadMore &&
        (state.loadState == LoadState.loadmore ||
            state.loadState == LoadState.done)) {
      return;
    }

    state = state.copyWith(
      loadState: loadMore ? LoadState.loadmore : LoadState.loading,
      errorMessage: null,
    );

    try {
      final response = await _repo.getArtisansList(page);
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'An error occurred';
      }

      final payload = response.data;
      final results = payload?.results ?? const [];
      final currentPage = payload?.page ?? page;
      final totalPages = payload?.totalPages ?? state.totalPages;
      final totalItems = payload?.totalItems ?? state.totalItems;
      final hasMorePages = currentPage < totalPages;

      state = state.copyWith(
        loadState: hasMorePages ? LoadState.success : LoadState.done,
        artisans: loadMore ? [...state.artisans, ...results] : results,
        currentPage: currentPage,
        totalPages: totalPages,
        totalItems: totalItems,
      );
    } catch (e) {
      state = state.copyWith(
        loadState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> requestQuotation({
    required String artisanId,
    required String clientNote,
    required DateTime clientEndDate,
    List<XFile> images = const [],
    required void Function(String message, QuotationModel? quotation)
        onSuccess,
    required void Function(String message) onError,
  }) async {
    state = state.copyWith(
      requestQuotationLoadState: LoadState.loading,
      errorMessage: null,
    );

    try {
      final imageUrls = images.isEmpty
          ? <String>[]
          : await _cloudinaryService.uploadImages(images);

      final requestBody = RequestQuotationRequestBody(
        clientNote: clientNote,
        images: imageUrls,
        clientEndDate: clientEndDate.toUtc().toIso8601String(),
      );

      debugLog(
        '[REQUEST QUOTATION][REQUEST] artisanId=$artisanId body=${requestBody.toJson()}',
      );

      final response = await _repo.requestQuotation(artisanId, requestBody);
      debugLog(
        '[REQUEST QUOTATION][RESPONSE] status=${response.status} '
        'message=${response.message} code=${response.code} '
        'error=${response.error?.toJson()} data=${response.data?.toJson()}',
      );
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'An error occurred';
      }

      state = state.copyWith(requestQuotationLoadState: LoadState.success);
      onSuccess(
        response.message ?? 'Quotation Request Sent.',
        response.data,
      );
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(
        requestQuotationLoadState: LoadState.error,
        errorMessage: message,
      );
      onError(message);
    }
  }
}
