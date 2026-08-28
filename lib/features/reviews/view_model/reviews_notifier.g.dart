// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewsNotifierHash() => r'2bf59c74c6cdb71fc3d69a0939aa6742c9b4e1de';

/// Reviews across all three subjects — booked listings, artisans and
/// marketplace items. They share one request body, so they share one notifier.
///
/// Copied from [ReviewsNotifier].
@ProviderFor(ReviewsNotifier)
final reviewsNotifierProvider =
    AutoDisposeNotifierProvider<ReviewsNotifier, ReviewsState>.internal(
  ReviewsNotifier.new,
  name: r'reviewsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reviewsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReviewsNotifier = AutoDisposeNotifier<ReviewsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
