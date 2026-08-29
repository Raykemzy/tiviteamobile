import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tivi_tea/features/login/view_model/login_notifier.dart';
import 'package:tivi_tea/features/login/view_model/login_state.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/models/enums/enums.dart';

/// Whether the signed-in account may buy from the marketplace.
///
/// Buying is client-only. Every cart endpoint answers 401 "Unauthorized user"
/// for partner and artisan tokens — verified against the live API — which
/// matches the rule Tolu set out: anything involving renting or buying is
/// available to clients only. Partners and artisans still browse and sell.
///
/// Guests count as buyers so the controls stay visible and can prompt a login,
/// which is where the sign-in prompt was always meant to appear.
bool canBuyInMarketplace(WidgetRef ref) {
  final isGuest =
      ref.watch(loginNotifierProvider).appAccessState == AppAccessState.guest;
  if (isGuest) return true;
  return ref.watch(userNotifierProvider).signedInEntityType ==
      EntityType.client;
}

/// True when the marketplace controls are visible only because the viewer is
/// a guest — tapping them should send them to sign in.
bool marketplaceNeedsLogin(WidgetRef ref) {
  return ref.watch(loginNotifierProvider).appAccessState ==
      AppAccessState.guest;
}
