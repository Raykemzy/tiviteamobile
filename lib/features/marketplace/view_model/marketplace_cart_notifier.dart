import 'dart:async';

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

  /// Quantity edits are applied locally instantly and synced to the server in a
  /// single request after a short idle delay (debounce), avoiding one network
  /// call per tap. The backend treats `quantity` as the absolute total for a
  /// cart line, so we send the final desired quantity rather than a delta.
  static const _syncDebounce = Duration(milliseconds: 600);
  Timer? _syncTimer;

  /// Pending absolute quantities to push, keyed by listing id.
  final Map<String, int> _pendingTargets = {};
  void Function(String message)? _pendingOnError;

  @override
  MarketplaceCartState build() {
    _repo = MarketplaceRepo(restClient: ref.read(restClient));
    ref.onDispose(() => _syncTimer?.cancel());
    return const MarketplaceCartState();
  }

  /// The current line in state matching [line], or null. Used so quantity edits
  /// always build on the latest optimistic value (rapid taps can pass a stale
  /// line captured in a previous build).
  MarketplaceCartLine? _currentLine(MarketplaceCartLine line) {
    final key = marketplaceLineKey(line);
    for (final l in state.lines) {
      if (marketplaceLineKey(l) == key) return l;
    }
    return null;
  }

  void _scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(_syncDebounce, _flushSync);
  }

  /// Pushes all pending quantity changes in one batch, then reconciles.
  Future<void> _flushSync() async {
    _syncTimer = null;
    if (_pendingTargets.isEmpty) return;
    final targets = Map<String, int>.from(_pendingTargets);
    _pendingTargets.clear();
    final onError = _pendingOnError;
    _pendingOnError = null;

    var hadError = false;
    for (final entry in targets.entries) {
      final result = await _repo.addOrRemoveMarketPlaceCartItem(
        itemId: entry.key,
        action: 'add',
        quantity: entry.value,
      );
      if (result.isSuccess() != true) {
        hadError = true;
        onError?.call(result.message ?? 'Could not update cart');
      }
    }
    // On error, do a visible reload so the UI reverts to server truth.
    await loadCart(silent: !hadError);
  }

  /// Flushes any pending quantity changes immediately. Call before actions that
  /// depend on the server cart being up to date (e.g. checkout).
  Future<void> commitPendingQuantity() async {
    _syncTimer?.cancel();
    await _flushSync();
  }

  /// Loads the cart from the server.
  ///
  /// Pass [silent] to reconcile in the background after an optimistic update —
  /// it avoids toggling [LoadState.loading] (no spinner/flicker) and keeps the
  /// current optimistic lines if the refresh fails.
  Future<void> loadCart({bool silent = false}) async {
    if (!silent) state = state.copyWith(loadState: LoadState.loading);
    final result = await _repo.getMarketPlaceCartItems();
    if (result.isSuccess() != true) {
      if (!silent) state = state.copyWith(loadState: LoadState.error);
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

  /// Returns a copy of the current lines with [target]'s quantity replaced.
  List<MarketplaceCartLine> _withQuantity(
    MarketplaceCartLine target,
    int quantity,
  ) {
    final key = marketplaceLineKey(target);
    return [
      for (final l in state.lines)
        if (marketplaceLineKey(l) == key)
          MarketplaceCartLine(
            cartItemId: l.cartItemId,
            listing: l.listing,
            quantity: quantity,
          )
        else
          l,
    ];
  }

  /// Returns a copy of the current lines with [target] removed.
  List<MarketplaceCartLine> _without(MarketplaceCartLine target) {
    final key = marketplaceLineKey(target);
    return [
      for (final l in state.lines)
        if (marketplaceLineKey(l) != key) l,
    ];
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
    // Don't exceed available stock.
    final stock = item.quantity;
    final inCart = state.lines.lineForListing(item)?.quantity ?? 0;
    if (stock != null && inCart >= stock) {
      onError?.call('Only $stock in stock');
      return false;
    }
    final newTotal = inCart + 1;
    // Optimistic: show the item/qty immediately, then sync the new total.
    state = state.copyWith(lines: _linesAfterAddingListing(item));
    _pendingTargets.remove(id);
    final result = await _repo.addOrRemoveMarketPlaceCartItem(
      itemId: id,
      action: 'add',
      quantity: newTotal,
    );
    if (result.isSuccess() != true) {
      onError?.call(result.message ?? 'Could not add to cart');
      await loadCart();
      return false;
    }
    // Skip reconcile while other quantity edits are still pending so we don't
    // clobber their optimistic values; the debounced flush reconciles later.
    if (_pendingTargets.isEmpty) await loadCart(silent: true);
    return true;
  }

  /// Local + debounced. Bumps the quantity instantly and queues a single sync.
  void increment(
    MarketplaceCartLine line, {
    void Function(String message)? onError,
  }) {
    final current = _currentLine(line) ?? line;
    final id = current.listing.id?.trim();
    if (id == null || id.isEmpty) {
      onError?.call('Item has no id');
      return;
    }
    if (!current.canIncrement) {
      onError?.call('Only ${current.availableStock} in stock');
      return;
    }
    final newQty = current.quantity + 1;
    state = state.copyWith(lines: _withQuantity(current, newQty));
    _pendingTargets[id] = newQty;
    _pendingOnError = onError;
    _scheduleSync();
  }

  /// Local + debounced. Lowers the quantity instantly (removing the line at 0).
  void decrement(
    MarketplaceCartLine line, {
    void Function(String message)? onError,
  }) {
    final current = _currentLine(line) ?? line;
    final id = current.listing.id?.trim();
    if (id == null || id.isEmpty) {
      onError?.call('Item has no id');
      return;
    }
    // Dropping below 1 removes the line entirely.
    if (current.quantity <= 1) {
      _pendingTargets.remove(id);
      removeLine(current, onError: onError);
      return;
    }
    final newQty = current.quantity - 1;
    state = state.copyWith(lines: _withQuantity(current, newQty));
    _pendingTargets[id] = newQty;
    _pendingOnError = onError;
    _scheduleSync();
  }

  Future<void> removeLine(
    MarketplaceCartLine line, {
    void Function(String message)? onError,
  }) async {
    final current = _currentLine(line) ?? line;
    final id = current.listing.id?.trim();
    if (id == null || id.isEmpty) {
      onError?.call('Item has no id');
      return;
    }
    _pendingTargets.remove(id);
    state = state.copyWith(lines: _without(current));
    final result = await _repo.addOrRemoveMarketPlaceCartItem(
      itemId: id,
      action: 'remove',
      quantity: current.quantity,
    );
    if (result.isSuccess() != true) {
      onError?.call(result.message ?? 'Could not remove from cart');
      await loadCart();
      return;
    }
    if (_pendingTargets.isEmpty) await loadCart(silent: true);
  }
}
