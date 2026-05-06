import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/home/model/client/category_response_model.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';

class ServicesState {
  ServicesState({
    required this.loadState,
    required this.listingLoadState,
    required this.listing,
    required this.categories,
    required this.currentPage,
    required this.totalPages,
    required this.hasMorePages,
    this.errorMessage,
    this.searchQuery,
  });
  factory ServicesState.initial() {
    return ServicesState(
      loadState: LoadState.loading,
      listingLoadState: LoadState.loading,
      categories: [],
      listing: [],
      currentPage: 1,
      totalPages: 1,
      hasMorePages: true,
    );
  }
  final LoadState loadState;
  final LoadState listingLoadState;
  final int currentPage;
  final int totalPages;
  final bool hasMorePages;
  final String? errorMessage;
  final String? searchQuery;
  final List<CategoryResponseModel> categories;
  final List<ListingResponseModel> listing;

  ServicesState copyWith({
    LoadState? loadState,
    LoadState? listingLoadState,
    int? currentPage,
    int? totalPages,
    bool? hasMorePages,
    Object? errorMessage = _noValue,
    Object? searchQuery = _noValue,
    List<CategoryResponseModel>? categories,
    List<ListingResponseModel>? listing,
  }) {
    return ServicesState(
      loadState: loadState ?? this.loadState,
      categories: categories ?? this.categories,
      listingLoadState: listingLoadState ?? this.listingLoadState,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      errorMessage: identical(errorMessage, _noValue)
          ? this.errorMessage
          : errorMessage as String?,
      searchQuery: identical(searchQuery, _noValue)
          ? this.searchQuery
          : searchQuery as String?,
      listing: listing ?? this.listing,
    );
  }
}

const Object _noValue = Object();
