import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';

class ArtisansState {
  const ArtisansState({
    required this.loadState,
    required this.requestQuotationLoadState,
    required this.artisans,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.errorMessage,
  });

  factory ArtisansState.initial() {
    return const ArtisansState(
      loadState: LoadState.loading,
      requestQuotationLoadState: LoadState.idle,
      artisans: [],
      currentPage: 0,
      totalPages: 1,
      totalItems: 0,
      errorMessage: null,
    );
  }

  final LoadState loadState;
  final LoadState requestQuotationLoadState;
  final List<ArtisanResponseModel> artisans;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String? errorMessage;

  ArtisansState copyWith({
    LoadState? loadState,
    LoadState? requestQuotationLoadState,
    List<ArtisanResponseModel>? artisans,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? errorMessage,
  }) {
    return ArtisansState(
      loadState: loadState ?? this.loadState,
      requestQuotationLoadState:
          requestQuotationLoadState ?? this.requestQuotationLoadState,
      artisans: artisans ?? this.artisans,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: errorMessage,
    );
  }
}
