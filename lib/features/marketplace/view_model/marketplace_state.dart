import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';

class MarketplaceState {
  const MarketplaceState({
    required this.loadState,
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.errorMessage,
  });

  factory MarketplaceState.initial() {
    return const MarketplaceState(
      loadState: LoadState.loading,
      items: [],
      currentPage: 0,
      totalPages: 1,
      totalItems: 0,
      errorMessage: null,
    );
  }

  final LoadState loadState;
  final List<ListingResponseModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String? errorMessage;

  MarketplaceState copyWith({
    LoadState? loadState,
    List<ListingResponseModel>? items,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? errorMessage,
  }) {
    return MarketplaceState(
      loadState: loadState ?? this.loadState,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: errorMessage,
    );
  }
}
