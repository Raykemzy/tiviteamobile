import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_order_models.dart';
import 'package:tivi_tea/repositories/marketplace/marketplace_repo.dart';

part 'marketplace_order_notifier.g.dart';

class MarketplaceOrderState {
  const MarketplaceOrderState({
    required this.loadState,
    this.order,
    this.dashboard,
    this.errorMessage,
  });

  factory MarketplaceOrderState.initial() =>
      const MarketplaceOrderState(loadState: LoadState.idle);

  final LoadState loadState;
  final MarketplaceOrderModel? order;
  final MarketplaceSellerDashboardModel? dashboard;
  final String? errorMessage;

  MarketplaceOrderState copyWith({
    LoadState? loadState,
    MarketplaceOrderModel? order,
    MarketplaceSellerDashboardModel? dashboard,
    String? errorMessage,
  }) {
    return MarketplaceOrderState(
      loadState: loadState ?? this.loadState,
      order: order ?? this.order,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class MarketplaceOrderNotifier extends _$MarketplaceOrderNotifier {
  late final MarketplaceRepo _repo;

  @override
  MarketplaceOrderState build() {
    _repo = MarketplaceRepo(restClient: ref.read(restClient));
    return MarketplaceOrderState.initial();
  }

  Future<void> viewOrder(String orderId) async {
    state = state.copyWith(loadState: LoadState.loading, errorMessage: null);
    try {
      final response = await _repo.viewOrder(orderId);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      state = state.copyWith(
        loadState: LoadState.success,
        order: response.data,
      );
    } catch (e) {
      state = state.copyWith(
        loadState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> getSellerDashboard() async {
    state = state.copyWith(loadState: LoadState.loading, errorMessage: null);
    try {
      final response = await _repo.getSellerDashboard();
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      state = state.copyWith(
        loadState: LoadState.success,
        dashboard: response.data,
      );
    } catch (e) {
      state = state.copyWith(
        loadState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }
}
