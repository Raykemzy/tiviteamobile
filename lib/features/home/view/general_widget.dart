import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tivi_tea/features/home/view/client/customer_home_screen.dart';
import 'package:tivi_tea/features/home/view/service_provider/service_provider_home_view.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/models/enums/enums.dart';

class GeneralHomeScreeen extends ConsumerStatefulWidget {
  const GeneralHomeScreeen({super.key});

  @override
  ConsumerState<GeneralHomeScreeen> createState() => _GeneralHomeScreeenState();
}

class _GeneralHomeScreeenState extends ConsumerState<GeneralHomeScreeen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    final entityType = user.signedInEntityType ?? EntityType.client;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        return;
      },
      child: switch (entityType) {
        EntityType.partner => const ServiceProviderHomeScreen(),
        EntityType.client => const CustomerHomeScreen(),
        EntityType.artisan => const CustomerHomeScreen(),
      },
    );
  }
}
