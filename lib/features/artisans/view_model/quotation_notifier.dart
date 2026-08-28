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
    this.quotation,
    this.errorMessage,
  });

  factory QuotationState.initial() =>
      const QuotationState(actionState: LoadState.idle);

  final LoadState actionState;
  final QuotationModel? quotation;
  final String? errorMessage;

  QuotationState copyWith({
    LoadState? actionState,
    QuotationModel? quotation,
    String? errorMessage,
  }) {
    return QuotationState(
      actionState: actionState ?? this.actionState,
      quotation: quotation ?? this.quotation,
      errorMessage: errorMessage,
    );
  }
}

/// Drives the artisan/client quotation negotiation.
///
/// Every action returns the updated quotation, which is the only way to read
/// one — the backend exposes no GET for quotations, so this notifier is seeded
/// with the quotation the caller already holds.
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
