import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/reviews/model/review_models.dart';
import 'package:tivi_tea/repositories/reviews/reviews_repo.dart';

part 'reviews_notifier.g.dart';

class ReviewsState {
  const ReviewsState({
    required this.submitState,
    required this.listState,
    this.bookingReviews = const [],
    this.artisanReviews = const [],
    this.errorMessage,
  });

  factory ReviewsState.initial() => const ReviewsState(
        submitState: LoadState.idle,
        listState: LoadState.idle,
      );

  final LoadState submitState;
  final LoadState listState;
  final List<BookingReviewModel> bookingReviews;
  final List<ArtisanReviewModel> artisanReviews;
  final String? errorMessage;

  ReviewsState copyWith({
    LoadState? submitState,
    LoadState? listState,
    List<BookingReviewModel>? bookingReviews,
    List<ArtisanReviewModel>? artisanReviews,
    String? errorMessage,
  }) {
    return ReviewsState(
      submitState: submitState ?? this.submitState,
      listState: listState ?? this.listState,
      bookingReviews: bookingReviews ?? this.bookingReviews,
      artisanReviews: artisanReviews ?? this.artisanReviews,
      errorMessage: errorMessage,
    );
  }
}

/// Reviews across all three subjects — booked listings, artisans and
/// marketplace items. They share one request body, so they share one notifier.
@riverpod
class ReviewsNotifier extends _$ReviewsNotifier {
  late final ReviewsRepo _repo;

  @override
  ReviewsState build() {
    _repo = ReviewsRepo(restClient: ref.read(restClient));
    return ReviewsState.initial();
  }

  Future<void> reviewBooking({
    required String bookingId,
    required int rating,
    required String note,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) =>
      _submit(
        () => _repo.reviewBooking(
          bookingId,
          SubmitReviewRequestBody(rating: rating, note: note),
        ),
        onSuccess: onSuccess,
        onError: onError,
      );

  Future<void> reviewArtisan({
    required String bookingId,
    required int rating,
    required String note,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) =>
      _submit(
        () => _repo.reviewArtisan(
          bookingId,
          SubmitReviewRequestBody(rating: rating, note: note),
        ),
        onSuccess: onSuccess,
        onError: onError,
      );

  Future<void> reviewMarketplaceItem({
    required String itemId,
    required int rating,
    required String note,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) =>
      _submit(
        () => _repo.reviewMarketplaceItem(
          itemId,
          SubmitReviewRequestBody(rating: rating, note: note),
        ),
        onSuccess: onSuccess,
        onError: onError,
      );

  /// Client confirms the job is done. Shares this notifier because it is the
  /// step that unlocks reviewing.
  Future<void> confirmServiceCompletion({
    required String bookingId,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) =>
      _submit(
        () => _repo.confirmServiceCompletion(bookingId),
        onSuccess: onSuccess,
        onError: onError,
      );

  Future<void> getPartnerBookingReviews({int page = 1}) async {
    state = state.copyWith(listState: LoadState.loading, errorMessage: null);
    try {
      final response = await _repo.getPartnerBookingReviews(page);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      state = state.copyWith(
        listState: LoadState.success,
        bookingReviews: response.data?.results ?? const [],
      );
    } catch (e) {
      state = state.copyWith(
        listState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> getArtisanReviews({
    required String artisanId,
    int page = 1,
  }) async {
    state = state.copyWith(listState: LoadState.loading, errorMessage: null);
    try {
      final response = await _repo.getArtisanReviews(artisanId, page);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      state = state.copyWith(
        listState: LoadState.success,
        artisanReviews: response.data?.results ?? const [],
      );
    } catch (e) {
      state = state.copyWith(
        listState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _submit(
    Future<dynamic> Function() action, {
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    state = state.copyWith(submitState: LoadState.loading, errorMessage: null);
    try {
      final response = await action();
      if (response.isSuccess() == false) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      state = state.copyWith(submitState: LoadState.success);
      onSuccess(response.message as String? ?? 'Done');
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(
        submitState: LoadState.error,
        errorMessage: message,
      );
      onError(message);
    }
  }
}
