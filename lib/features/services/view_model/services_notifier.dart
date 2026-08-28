import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';
import 'package:tivi_tea/features/services/view_model/services_state.dart';
import 'package:tivi_tea/repositories/services/general/general_services_repo.dart';

part 'services_notifier.g.dart';

@riverpod
class ServicesNotifer extends _$ServicesNotifer {
  late final GeneralServicesRepo _repo;

  @override
  ServicesState build() {
    _repo = GeneralServicesRepo(restClient: ref.read(restClient));

    return ServicesState.initial();
  }

  void getCategories() async {
    try {
      final response = await _repo.getCategories();
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? '';
      }
      state = state.copyWith(
        loadState: LoadState.success,
        categories: response.data?.results ?? [],
      );
    } catch (e) {
      state = state.copyWith(loadState: LoadState.error);
    }
  }

  /// Re-queries the catalogue for [categoryId], or clears the filter when it
  /// is null.
  ///
  /// The backend ignores `category`/`category_id` on `/listings/` — verified
  /// against the live API — but its `name` query matches category names as
  /// well as listing names, so the category's *name* is what gets sent.
  /// Filtering client-side (the previous behaviour) only ever filtered the
  /// page already in memory, so picking a category hid most of the catalogue
  /// and paginating past it silently dropped the filter.
  Future<void> filterByCategory(String? categoryId) {
    if (categoryId == null) return getListing();
    final name = state.categories
        .where((category) => category.id == categoryId)
        .map((category) => category.name)
        .firstOrNull;
    return getListing(name: name);
  }

  Future<void> getListing({
    int page = 1,
    bool loadmore = false,
    String? name,
  }) async {
    if (loadmore &&
        (state.listingLoadState == LoadState.loadmore || !state.hasMorePages)) {
      return;
    }

    final effectiveName = loadmore ? state.searchQuery : name;

    state = state.copyWith(
      listingLoadState: loadmore ? LoadState.loadmore : LoadState.loading,
      hasMorePages: loadmore ? state.hasMorePages : true,
      errorMessage: null,
      searchQuery: loadmore ? state.searchQuery : name,
    );

    try {
      final response = await _repo.getListing(page, name: effectiveName);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? '';
      }
      final payload = response.data;
      final listings = payload?.results ?? const [];
      final currentPage = payload?.page ?? page;
      final totalPages = payload?.totalPages ?? state.totalPages;
      final hasReliableTotalPages = (payload?.totalPages ?? 0) > 0;
      final hasMorePages = listings.isNotEmpty &&
          (!hasReliableTotalPages || currentPage < totalPages);

      state = state.copyWith(
        listingLoadState: hasMorePages ? LoadState.success : LoadState.done,
        currentPage: currentPage,
        totalPages: totalPages,
        hasMorePages: hasMorePages,
        listing: loadmore ? [...state.listing, ...listings] : listings,
      );
    } catch (e) {
      state = state.copyWith(
        listingLoadState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ListingResponseModel?> getListingbyId(String listingId) async {
    try {
      final response = await _repo.getListingById(listingId);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? '';
      }
      return response.data;
    } catch (e) {
      state = state.copyWith(loadState: LoadState.error);
      return null;
    }
  }

  bool get isLoading => state.loadState == LoadState.loading;
}
