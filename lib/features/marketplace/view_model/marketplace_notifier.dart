import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_state.dart';
import 'package:tivi_tea/repositories/marketplace/marketplace_repo.dart';

part 'marketplace_notifier.g.dart';

@riverpod
class MarketplaceNotifier extends _$MarketplaceNotifier {
  late final MarketplaceRepo _repo;

  @override
  MarketplaceState build() {
    _repo = MarketplaceRepo(restClient: ref.read(restClient));
    return MarketplaceState.initial();
  }

  Future<void> getMarketPlaceItems({int page = 1, bool loadMore = false}) async {
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
      final response = await _repo.getMarketPlaceItems(page: page);
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
        items: loadMore ? [...state.items, ...results] : results,
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
