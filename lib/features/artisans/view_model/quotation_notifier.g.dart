// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quotationNotifierHash() => r'277a0ba2c864799bd94f12332cf450a5b8321889';

/// Drives the artisan/client quotation negotiation.
///
/// Callers seed it with whatever they already hold (possibly just an id from
/// a notification) and then [load] the full record from
/// `/bookings/quote/{id}`; every action afterwards returns the updated
/// quotation.
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
