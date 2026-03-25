import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_line.dart';
import 'package:tivi_tea/repositories/marketplace/marketplace_repo.dart';

part 'marketplace_cart_notifier.g.dart';

class MarketplaceCartState {
  const MarketplaceCartState({
    this.lines = const [],
    this.loadState = LoadState.idle,
  });

  final List<MarketplaceCartLine> lines;
  final LoadState loadState;

  MarketplaceCartState copyWith({
    List<MarketplaceCartLine>? lines,
    LoadState? loadState,
  }) =>
      MarketplaceCartState(
        lines: lines ?? this.lines,
        loadState: loadState ?? this.loadState,
      );
}

@Riverpod(keepAlive: true)
class MarketplaceCart extends _$MarketplaceCart {
  late final MarketplaceRepo _repo;

  @override
  MarketplaceCartState build() {
    _repo = MarketplaceRepo(restClient: ref.read(restClient));
    return const MarketplaceCartState();
  }

  Future<void> loadCart() async {
    state = state.copyWith(loadState: LoadState.loading);
    final result = await _repo.getMarketPlaceCartItems();
    if (result.isSuccess() != true) {
      state = state.copyWith(loadState: LoadState.error);
      return;
    }
    final raw = result.data?.results ?? [];
    final lines = raw
        .map(
          (m) => MarketplaceCartLine(
            cartItemId: m.id,
            listing: m.listing,
            quantity: m.quantity,
          ),
        )
        .toList();
    state = MarketplaceCartState(lines: lines, loadState: LoadState.success);
  }

  List<MarketplaceCartLine> _linesAfterAddingListing(
    ListingResponseModel item,
  ) {
    final key = marketplaceCartLineKey(item);
    final idx = state.lines.indexWhere(
      (l) => marketplaceCartLineKey(l.listing) == key,
    );
    if (idx < 0) {
      return [
        ...state.lines,
        MarketplaceCartLine(
          cartItemId: null,
          listing: item,
          quantity: 1,
        ),
      ];
    }
    final line = state.lines[idx];
    return [
      ...state.lines.sublist(0, idx),
      MarketplaceCartLine(
        cartItemId: line.cartItemId,
        listing: line.listing,
        quantity: line.quantity + 1,
      ),
      ...state.lines.sublist(idx + 1),
    ];
  }

  Future<bool> addItem(
    ListingResponseModel item, {
    void Function(String message)? onError,
  }) async {
    final id = item.id?.trim();
    if (id == null || id.isEmpty) {
      onError?.call('Item has no id');
      return false;
    }
    state = state.copyWith(loadState: LoadState.loading);
    final result = await _repo.addOrRemoveMarketPlaceCartItem(
      itemId: id,
      action: 'add',
      quantity: 1,
    );
    if (result.isSuccess() != true) {
      state = state.copyWith(loadState: LoadState.error);
      onError?.call(result.message ?? 'Could not add to cart');
      await loadCart();
      return false;
    }
    // Immediate UI feedback; then reconcile with server (cart line ids, exact qty).
    state = MarketplaceCartState(
      lines: _linesAfterAddingListing(item),
      loadState: LoadState.success,
    );
    await loadCart();
    return true;
  }

  Future<void> increment(
    MarketplaceCartLine line, {
    void Function(String message)? onError,
  }) async {
    final id = line.listing.id?.trim();
    if (id == null || id.isEmpty) {
      onError?.call('Item has no id');
      return;
    }
    state = state.copyWith(loadState: LoadState.loading);
    final result = await _repo.addOrRemoveMarketPlaceCartItem(
      itemId: id,
      action: 'add',
      quantity: 1,
    );
    if (result.isSuccess() != true) {
      state = state.copyWith(loadState: LoadState.error);
      onError?.call(result.message ?? 'Could not update cart');
      await loadCart();
      return;
    }
    await loadCart();
  }

  Future<void> decrement(
    MarketplaceCartLine line, {
    void Function(String message)? onError,
  }) async {
    final id = line.listing.id?.trim();
    if (id == null || id.isEmpty) {
      onError?.call('Item has no id');
      return;
    }
    state = state.copyWith(loadState: LoadState.loading);
    final result = await _repo.addOrRemoveMarketPlaceCartItem(
      itemId: id,
      action: 'remove',
      quantity: 1,
    );
    if (result.isSuccess() != true) {
      state = state.copyWith(loadState: LoadState.error);
      onError?.call(result.message ?? 'Could not update cart');
      await loadCart();
      return;
    }
    await loadCart();
  }

  Future<void> removeLine(
    MarketplaceCartLine line, {
    void Function(String message)? onError,
  }) async {
    final id = line.listing.id?.trim();
    if (id == null || id.isEmpty) {
      onError?.call('Item has no id');
      return;
    }
    state = state.copyWith(loadState: LoadState.loading);
    final result = await _repo.addOrRemoveMarketPlaceCartItem(
      itemId: id,
      action: 'remove',
      quantity: line.quantity,
    );
    if (result.isSuccess() != true) {
      state = state.copyWith(loadState: LoadState.error);
      onError?.call(result.message ?? 'Could not remove from cart');
      await loadCart();
      return;
    }
    await loadCart();
  }
}
