import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/artisans/view_model/artisans_state.dart';
import 'package:tivi_tea/repositories/artisans/artisans_repo.dart';

part 'artisans_notifier.g.dart';

@riverpod
class ArtisansNotifier extends _$ArtisansNotifier {
  late final ArtisansRepo _repo;

  @override
  ArtisansState build() {
    _repo = ArtisansRepo(restClient: ref.read(restClient));
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
        throw response.error?.message ?? response.message ?? 'An error occurred';
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
}
