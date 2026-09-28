// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotations_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quotationsListNotifierHash() =>
    r'62dba820e9d98e759ec55c7c0fc22d215b28dddd';

/// Every quotation the signed-in entity is party to, from
/// `/bookings/quotation/list`. Works for clients and artisans alike — the
/// backend scopes the list to the caller.
///
/// Copied from [QuotationsListNotifier].
@ProviderFor(QuotationsListNotifier)
final quotationsListNotifierProvider = AutoDisposeNotifierProvider<
    QuotationsListNotifier, QuotationsListState>.internal(
  QuotationsListNotifier.new,
  name: r'quotationsListNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quotationsListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuotationsListNotifier = AutoDisposeNotifier<QuotationsListState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
