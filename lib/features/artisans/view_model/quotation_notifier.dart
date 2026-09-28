import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/artisans/model/quotation_model.dart';
import 'package:tivi_tea/features/artisans/model/quotation_request_bodies.dart';
import 'package:tivi_tea/repositories/artisans/artisans_repo.dart';

part 'quotation_notifier.g.dart';

class QuotationState {
  const QuotationState({
    required this.actionState,
    required this.loadState,
    this.quotation,
    this.errorMessage,
  });

  factory QuotationState.initial() => const QuotationState(
        actionState: LoadState.idle,
        loadState: LoadState.idle,
      );

  /// Send / counter / accept / decline.
  final LoadState actionState;

  /// Fetching the quotation itself via [QuotationNotifier.load].
  final LoadState loadState;
  final QuotationModel? quotation;
  final String? errorMessage;

  QuotationState copyWith({
    LoadState? actionState,
    LoadState? loadState,
    QuotationModel? quotation,
    String? errorMessage,
  }) {
    return QuotationState(
      actionState: actionState ?? this.actionState,
      loadState: loadState ?? this.loadState,
      quotation: quotation ?? this.quotation,
      errorMessage: errorMessage,
    );
  }
}

/// Drives the artisan/client quotation negotiation.
///
/// Callers seed it with whatever they already hold (possibly just an id from
/// a notification) and then [load] the full record from
/// `/bookings/quote/{id}`; every action afterwards returns the updated
/// quotation.
@riverpod
class QuotationNotifier extends _$QuotationNotifier {
  late final ArtisansRepo _repo;

  @override
  QuotationState build() {
    _repo = ArtisansRepo(restClient: ref.read(restClient));
    return QuotationState.initial();
  }

  void seed(QuotationModel quotation) {
    state = state.copyWith(quotation: quotation);
  }

  /// Replaces the seeded quotation with the backend's full copy. Keeps the
  /// seed on failure so the screen still has something to render.
  Future<void> load(String quotationId) async {
    state = state.copyWith(loadState: LoadState.loading, errorMessage: null);
    try {
      final response = await _repo.getQuotation(quotationId);
      if (!response.isSuccess()) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      state = state.copyWith(
        loadState: LoadState.success,
        quotation: response.data,
      );
    } catch (e) {
      state = state.copyWith(
        loadState: LoadState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> sendQuotation({
    required String quotationId,
    required String note,
    required num price,
    required DateTime endDate,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) {
    return _run(
      () => _repo.sendQuotation(
        quotationId,
        SendQuotationRequestBody(
          artisanNote: note,
          artisanPrice: price,
          artisanEndDate: endDate.toUtc().toIso8601String(),
        ),
      ),
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> counter({
    required String quotationId,
    required bool asArtisan,
    required String note,
    required num price,
    required DateTime endDate,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) {
    final iso = endDate.toUtc().toIso8601String();
    final body = asArtisan
        ? CounterQuotationRequestBody.artisan(
            note: note, price: price, endDate: iso)
        : CounterQuotationRequestBody.client(
            note: note, price: price, endDate: iso);
    return _run(
      () => _repo.counterQuotationPrice(quotationId, body),
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> respond({
    required String quotationId,
    required bool accept,
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) {
    return _run(
      () => _repo.acceptOrDeclineQuotation(quotationId, accept: accept),
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> _run(
    Future<dynamic> Function() action, {
    required void Function(String message) onSuccess,
    required void Function(String message) onError,
  }) async {
    state = state.copyWith(actionState: LoadState.loading, errorMessage: null);
    try {
      final response = await action();
      if (response.isSuccess() == false) {
        throw response.error?.message ?? response.message ?? 'An error occurred';
      }
      state = state.copyWith(
        actionState: LoadState.success,
        quotation: response.data as QuotationModel?,
      );
      onSuccess(response.message as String? ?? 'Done');
    } catch (e) {
      final message = e.toString();
      state = state.copyWith(
        actionState: LoadState.error,
        errorMessage: message,
      );
      onError(message);
    }
  }
}
