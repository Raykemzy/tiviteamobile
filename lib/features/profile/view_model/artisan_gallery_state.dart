import 'package:tivi_tea/core/utils/enums.dart';

class ArtisanGalleryState {
  const ArtisanGalleryState({
    required this.fetchState,
    required this.uploadState,
    required this.media,
    this.errorMessage,
  });

  factory ArtisanGalleryState.initial() {
    return const ArtisanGalleryState(
      fetchState: LoadState.idle,
      uploadState: LoadState.idle,
      media: [],
      errorMessage: null,
    );
  }

  /// Loading state for fetching the existing gallery.
  final LoadState fetchState;

  /// Loading state for uploading / removing media.
  final LoadState uploadState;

  /// Remote Cloudinary URLs currently saved on the artisan profile.
  final List<String> media;

  final String? errorMessage;

  ArtisanGalleryState copyWith({
    LoadState? fetchState,
    LoadState? uploadState,
    List<String>? media,
    String? errorMessage,
  }) {
    return ArtisanGalleryState(
      fetchState: fetchState ?? this.fetchState,
      uploadState: uploadState ?? this.uploadState,
      media: media ?? this.media,
      errorMessage: errorMessage,
    );
  }
}
