import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tivi_tea/features/home/view/general/all_listing_view.dart';

class ServicesView extends ConsumerWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Browsing is open to everyone, including guests and unverified clients.
    // KYC is enforced on the actions that need it (booking, creating a
    // listing) via `guardWithKyc` — walling off this tab locked unverified
    // clients out of the catalogue entirely.
    return const AllListingsView();
  }
}
