import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/search_text_field.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_item_detail_dialog.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/marketplace_listing_card.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_notifier.dart';
import 'package:tivi_tea/features/registration/view/widgets/registration_appbar.dart';

class MarketplaceView extends ConsumerStatefulWidget {
  const MarketplaceView({super.key});

  @override
  ConsumerState<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends ConsumerState<MarketplaceView> {
  static const int _defaultItemsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceNotifierProvider.notifier).getMarketPlaceItems();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceNotifierProvider);
    final searchTerm = _searchController.text.trim().toLowerCase();
    final filteredItems = state.items.where((item) {
      if (searchTerm.isEmpty) return true;
      final name = (item.name ?? '').toLowerCase();
      final desc = (item.description ?? '').toLowerCase();
      final addr = (item.address ?? '').toLowerCase();
      return name.contains(searchTerm) ||
          desc.contains(searchTerm) ||
          addr.contains(searchTerm);
    }).toList();

    final totalResults =
        state.totalItems > 0 ? state.totalItems : state.items.length;
    final hasSearch = searchTerm.isNotEmpty;
    int start = 0, end = 0;
    if (filteredItems.isNotEmpty) {
      start = hasSearch
          ? 1
          : ((math.max(state.currentPage, 1) - 1) * _defaultItemsPerPage) + 1;
      end = hasSearch ? filteredItems.length : start + filteredItems.length - 1;
      if (totalResults > 0) end = math.min(end, totalResults);
    }

    final isInitialLoading =
        state.loadState == LoadState.loading && state.items.isEmpty;

    return AppScaffold(
      appbar: const RegistrationAppBar(
        showCartIcon: true,
        headerSectionTitle: 'Marketplace',
        headerSectionSubtitle: 'Browse and add items to your cart',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: context.width,
                child: SearchTextField(
                  hintText: 'Search marketplace',
                  controller: _searchController,
                  padding: SizedBox(height: 14.h),
                ),
              ),
              10.verticalSpace,
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Showing $start - $end out of $totalResults Results',
                  style: context.theme.textTheme.labelMedium,
                ),
              ),
              12.verticalSpace,
              Builder(
                builder: (context) {
                  if (isInitialLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.loadState == LoadState.error &&
                      state.items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage ?? 'Failed to load items'),
                          12.verticalSpace,
                          ElevatedButton(
                            onPressed: () => _onRetry(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (filteredItems.isEmpty) {
                    return const Center(child: Text('No items found'));
                  }
                  return GridView.builder(
                    itemCount: filteredItems.length,
                    padding: EdgeInsets.only(bottom: 16.h),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      // width/height; higher ratio => shorter tiles, less empty space
                      // below short cards (keep ~0.55–0.60 if tall content overflows).
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return MarketplaceListingCard(
                        item: item,
                        onTap: () => MarketplaceItemDetailDialog.show(context, item),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRetry() {
    ref.read(marketplaceNotifierProvider.notifier).getMarketPlaceItems();
  }
}
