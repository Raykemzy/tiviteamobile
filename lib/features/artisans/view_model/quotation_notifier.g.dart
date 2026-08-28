// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quotationNotifierHash() => r'ead68b1240c7b9480d0fee65bf81b2b0966d8323';

/// Drives the artisan/client quotation negotiation.
///
/// Every action returns the updated quotation, which is the only way to read
/// one — the backend exposes no GET for quotations, so this notifier is seeded
/// with the quotation the caller already holds.
///
/// Copied from [QuotationNotifier].
@ProviderFor(QuotationNotifier)
final quotationNotifierProvider =
    AutoDisposeNotifierProvider<QuotationNotifier, QuotationState>.internal(
  QuotationNotifier.new,
  name: r'quotationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quotationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuotationNotifier = AutoDisposeNotifier<QuotationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
