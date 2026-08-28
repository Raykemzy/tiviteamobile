import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/features/services/view/widgets/kyc_dialog.dart';

/// Runs [onAllowed] only when the signed-in entity has passed KYC, otherwise
/// prompts for it.
///
/// KYC used to be enforced by swapping the whole Services tab for the KYC
/// screen, which locked unverified clients out of simply *browsing* — they
/// only need KYC to rent or book. The gate belongs on the actions that
/// genuinely require it: creating a listing, and booking (see
/// `BookNowWidget._navigateToNextView`).
void guardWithKyc(
  BuildContext context,
  WidgetRef ref, {
  required VoidCallback onAllowed,
}) {
  final user = ref.read(userNotifierProvider);
  if (user.kycIsVerified == true) {
    onAllowed();
    return;
  }
  context.showCustomDialog(child: const KYCDialog());
}
