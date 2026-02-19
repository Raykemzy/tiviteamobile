import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/marketplace/model/owner_marketplace_item_model.dart';

class OwnerMarketplaceState {
  const OwnerMarketplaceState({
    required this.loadState,
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.errorMessage,
    this.createLoadState,
    this.editLoadState,
    this.deletingItemId,
  });

  factory OwnerMarketplaceState.initial() {
    return const OwnerMarketplaceState(
      loadState: LoadState.loading,
      items: [],
      currentPage: 0,
      totalPages: 1,
      totalItems: 0,
      errorMessage: null,
      createLoadState: LoadState.idle,
      editLoadState: LoadState.idle,
      deletingItemId: null,
    );
  }

  final LoadState loadState;
  final List<OwnerMarketplaceItemModel> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String? errorMessage;
  final LoadState? createLoadState;
  final LoadState? editLoadState;
  final String? deletingItemId;

  OwnerMarketplaceState copyWith({
    LoadState? loadState,
    List<OwnerMarketplaceItemModel>? items,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? errorMessage,
    LoadState? createLoadState,
    LoadState? editLoadState,
    String? deletingItemId,
  }) {
    return OwnerMarketplaceState(
      loadState: loadState ?? this.loadState,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: errorMessage,
      createLoadState: createLoadState ?? this.createLoadState,
      editLoadState: editLoadState ?? this.editLoadState,
      deletingItemId: deletingItemId,
    );
  }
}
