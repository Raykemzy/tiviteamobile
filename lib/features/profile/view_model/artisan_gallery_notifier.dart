import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/services/third_party_services/cloudinary_service.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/profile/model/edit_profile_model.dart';
import 'package:tivi_tea/features/profile/view_model/artisan_gallery_state.dart';
import 'package:tivi_tea/features/profile/view_model/profile_notifer.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/repositories/artisans/artisans_repo.dart';

part 'artisan_gallery_notifier.g.dart';

@riverpod
class ArtisanGalleryNotifier extends _$ArtisanGalleryNotifier {
  late final ArtisansRepo _repo;
  late final CloudinaryService _cloudinaryService;

  @override
  ArtisanGalleryState build() {
    const String cloudName = 'tivitea';
    const String uploadPreset = 'hobmtu4o';
    _repo = ArtisansRepo(restClient: ref.read(restClient));
    _cloudinaryService = CloudinaryService(
      cloudinary: CloudinaryPublic(cloudName, uploadPreset),
    );
    return ArtisanGalleryState.initial();
  }

  /// Fetches the logged-in artisan's existing gallery via the view-artisan
  /// endpoint, keyed by the user's id.
  Future<void> fetchGallery() async {
    final userId = ref.read(userNotifierProvider).id;
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(fetchState: LoadState.error);
      return;
    }

    state = state.copyWith(fetchState: LoadState.loading, errorMessage: null);
    try {
      final response = await _repo.getArtisan(userId);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      state = state.copyWith(
        fetchState: LoadState.success,
        media: response.data?.galleryImages ?? const [],
      );
    } catch (e) {
      state = state.copyWith(
        fetchState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Uploads picked [files] to Cloudinary and appends the resulting URLs to
  /// the gallery, then persists via the edit-profile endpoint.
  Future<void> addMedia(
    List<XFile> files, {
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    if (files.isEmpty) return;

    state = state.copyWith(uploadState: LoadState.loading, errorMessage: null);
    try {
      final uploaded = await _cloudinaryService.uploadImages(files);
      if (uploaded.isEmpty) {
        throw 'Failed to upload media. Please try again.';
      }
      final merged = [...state.media, ...uploaded];
      await _persist(
        merged,
        onSuccess: () => onSuccess('Gallery updated'),
        onError: onError,
      );
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(
        uploadState: LoadState.error,
        errorMessage: message,
      );
      onError(message);
    }
  }

  /// Removes [url] from the gallery and persists the change.
  Future<void> removeMedia(
    String url, {
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    state = state.copyWith(uploadState: LoadState.loading, errorMessage: null);
    final updated = state.media.where((m) => m != url).toList();
    await _persist(
      updated,
      onSuccess: () => onSuccess('Removed from gallery'),
      onError: onError,
    );
  }

  /// Sends the full [media] list to the edit-profile endpoint via the profile
  /// notifier (which merges the remaining profile fields and refreshes user).
  Future<void> _persist(
    List<String> media, {
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    ref.read(profileNotiferProvider.notifier).updateProfile(
          EditProfileModel(artisanGalleryImages: media),
          onSuccess: () {
            state = state.copyWith(
              uploadState: LoadState.success,
              media: media,
            );
            onSuccess();
          },
          onError: (message) {
            state = state.copyWith(
              uploadState: LoadState.error,
              errorMessage: message,
            );
            onError(message);
          },
        );
  }
}
