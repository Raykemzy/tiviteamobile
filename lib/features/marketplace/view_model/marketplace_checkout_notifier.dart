import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_create_order_request_body.dart';
import 'package:tivi_tea/repositories/marketplace/marketplace_repo.dart';

part 'marketplace_checkout_notifier.g.dart';

@Riverpod(keepAlive: true)
class MarketplaceCheckout extends _$MarketplaceCheckout {
  late final MarketplaceRepo _repo;

  @override
  LoadState build() {
    _repo = MarketplaceRepo(restClient: ref.read(restClient));
    return LoadState.idle;
  }

  /// POST `/listings/market-place/order`. Returns order id on success.
  Future<String?> createOrder(MarketplaceCreateOrderRequestBody body) async {
    state = LoadState.loading;
    try {
      final result = await _repo.createMarketPlaceOrder(body);
      if (result.isSuccess() != true) {
        state = LoadState.error;
        throw result.message ?? 'Order failed';
      }
      state = LoadState.success;
      return result.data?.resolvedOrderId;
    } catch (_) {
      state = LoadState.error;
      rethrow;
    }
  }

  void reset() => state = LoadState.idle;
}
