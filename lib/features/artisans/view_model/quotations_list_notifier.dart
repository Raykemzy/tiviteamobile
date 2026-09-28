import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/artisans/model/quotation_model.dart';
import 'package:tivi_tea/repositories/artisans/artisans_repo.dart';

part 'quotations_list_notifier.g.dart';

class QuotationsListState {
  const QuotationsListState({
    required this.loadState,
    required this.quotations,
    required this.page,
    required this.hasMore,
    this.errorMessage,
  });

  factory QuotationsListState.initial() => const QuotationsListState(
        loadState: LoadState.idle,
        quotations: [],
        page: 1,
        hasMore: true,
      );

  final LoadState loadState;
  final List<QuotationModel> quotations;
  final int page;
  final bool hasMore;
  final String? errorMessage;

  QuotationsListState copyWith({
    LoadState? loadState,
    List<QuotationModel>? quotations,
    int? page,
    bool? hasMore,
    String? errorMessage,
  }) {
    return QuotationsListState(
      loadState: loadState ?? this.loadState,
      quotations: quotations ?? this.quotations,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

/// Every quotation the signed-in entity is party to, from
/// `/bookings/quotation/list`. Works for clients and artisans alike — the
/// backend scopes the list to the caller.
@riverpod
class QuotationsListNotifier extends _$QuotationsListNotifier {
  late final ArtisansRepo _repo;

  @override
  QuotationsListState build() {
    _repo = ArtisansRepo(restClient: ref.read(restClient));
    return QuotationsListState.initial();
  }

  Future<void> refresh() => _fetch(page: 1);

  Future<void> loadMore() {
    if (!state.hasMore || state.loadState == LoadState.loadmore) {
      return Future.value();
    }
    return _fetch(page: state.page + 1);
  }

  Future<void> _fetch({required int page}) async {
    state = state.copyWith(
      loadState: page == 1 ? LoadState.loading : LoadState.loadmore,
      errorMessage: null,
    );
    try {
      final response = await _repo.getQuotations(page);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      final data = response.data;
      final results = data?.results ?? const <QuotationModel>[];
      final totalPages = data?.totalPages ?? page;
      state = state.copyWith(
        loadState: LoadState.success,
        quotations: page == 1 ? results : [...state.quotations, ...results],
        page: page,
        hasMore: page < totalPages,
      );
    } catch (e) {
      state = state.copyWith(
        loadState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }
}
