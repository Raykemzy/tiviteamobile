import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/services/third_party_services/cloudinary_service.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/marketplace/model/create_marketplace_item_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/edit_marketplace_item_request_body.dart';
import 'package:tivi_tea/features/marketplace/model/owner_marketplace_item_model.dart';
import 'package:tivi_tea/features/marketplace/view_model/owner_marketplace_state.dart';
import 'package:tivi_tea/repositories/marketplace/marketplace_repo.dart';

part 'owner_marketplace_notifier.g.dart';

@riverpod
class OwnerMarketplaceNotifier extends _$OwnerMarketplaceNotifier {
  late final MarketplaceRepo _repo;
  late final CloudinaryService _cloudinaryService;

  @override
  OwnerMarketplaceState build() {
    const String cloudName = 'tivitea';
    const String uploadPreset = 'hobmtu4o';
    _repo = MarketplaceRepo(restClient: ref.read(restClient));
    _cloudinaryService = CloudinaryService(
      cloudinary: CloudinaryPublic(cloudName, uploadPreset),
    );
    return OwnerMarketplaceState.initial();
  }

  Future<void> getOwnersMarketPlaceItems({
    int page = 1,
    bool loadMore = false,
    bool silent = false,
  }) async {
    if (loadMore &&
        (state.loadState == LoadState.loadmore ||
            state.loadState == LoadState.done)) {
      return;
    }

    if (!silent) {
      state = state.copyWith(
        loadState: loadMore ? LoadState.loadmore : LoadState.loading,
        errorMessage: null,
      );
    }

    try {
      final response = await _repo.getOwnersMarketPlaceItems(page: page);
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
      if (!silent) {
        state = state.copyWith(
          loadState: LoadState.error,
          errorMessage: e.toString(),
        );
      }
    }
  }

  void _syncInBackground() {
    getOwnersMarketPlaceItems(page: 1, silent: true);
  }

  Future<void> createMarketplaceItem({
    required String name,
    required String description,
    required num price,
    required bool inStock,
    required List<XFile> images,
    required String category,
    required int quantity,
    required String pickUpAddress,
    required String condition,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    state = state.copyWith(
      createLoadState: LoadState.loading,
      errorMessage: null,
    );

    try {
      final imageUrls = images.isEmpty
          ? <String>[]
          : await _cloudinaryService.uploadImages(images);

      final requestBody = CreateMarketplaceItemRequestBody(
        name: name,
        description: description,
        price: price,
        inStock: inStock,
        images: imageUrls,
        category: category,
        quantity: quantity,
        pickUpAddress: pickUpAddress,
        condition: condition,
      );

      final response = await _repo.createMarketplaceItem(requestBody);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }

      state = state.copyWith(createLoadState: LoadState.success);
      onSuccess(response.message ?? 'Item created successfully.');
      _syncInBackground();
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(
        createLoadState: LoadState.error,
        errorMessage: message,
      );
      onError(message);
    }
  }

  Future<void> editMarketplaceItem({
    required String itemId,
    required num price,
    required bool inStock,
    required int quantity,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    state = state.copyWith(
      editLoadState: LoadState.loading,
      errorMessage: null,
    );

    try {
      final requestBody = EditMarketplaceItemRequestBody(
        price: price,
        inStock: inStock,
        quantity: quantity,
      );

      final response = await _repo.editMarketplaceItem(itemId, requestBody);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }

      final updatedItems = state.items.map((item) {
        if (item.id == itemId) {
          return OwnerMarketplaceItemModel(
            id: item.id,
            name: item.name,
            description: item.description,
            images: item.images,
            user: item.user,
            price: price,
            inStock: inStock,
            quantity: quantity,
            category: item.category,
          );
        }
        return item;
      }).toList();
      state = state.copyWith(
        items: updatedItems,
        editLoadState: LoadState.success,
      );
      onSuccess(response.message ?? 'Item updated successfully.');
      _syncInBackground();
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(
        editLoadState: LoadState.error,
        errorMessage: message,
      );
      onError(message);
    }
  }

  /// Publishes a draft item so it becomes visible in the marketplace.
  ///
  /// Items are created as drafts; without this the seller sees them under
  /// "My Marketplace" but no buyer ever sees them listed.
  Future<void> publishMarketplaceItem({
    required String itemId,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    state = state.copyWith(publishingItemId: itemId, errorMessage: null);
    try {
      final response = await _repo.publishMarketplaceItem(itemId);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      state = state.copyWith(publishingItemId: null);
      onSuccess(response.message ?? 'Item published.');
      await getOwnersMarketPlaceItems(page: 1);
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(publishingItemId: null, errorMessage: message);
      onError(message);
    }
  }

  Future<void> deleteMarketplaceItem({
    required String itemId,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    state = state.copyWith(deletingItemId: itemId, errorMessage: null);

    try {
      final response = await _repo.deleteMarketplaceItem(itemId);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }

      final newItems =
          state.items.where((item) => item.id != itemId).toList();
      final newTotal = (state.totalItems > 0) ? state.totalItems - 1 : 0;
      state = state.copyWith(
        items: newItems,
        totalItems: newTotal,
        deletingItemId: null,
      );
      onSuccess(response.message ?? 'Item deleted successfully.');
      _syncInBackground();
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(deletingItemId: null, errorMessage: message);
      onError(message);
    }
  }
}
