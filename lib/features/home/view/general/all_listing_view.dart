import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/search_text_field.dart';
import 'package:tivi_tea/features/home/view/widgets/category_section.dart';
import 'package:tivi_tea/features/home/view/widgets/secondary_listing_widget.dart';
import 'package:tivi_tea/features/services/view_model/services_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class AllListingsView extends ConsumerStatefulWidget {
  const AllListingsView({super.key});

  @override
  ConsumerState<AllListingsView> createState() => _AllListingsViewState();
}

class _AllListingsViewState extends ConsumerState<AllListingsView> {
  String? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final state = ref.read(servicesNotiferProvider);
      final notifier = ref.read(servicesNotiferProvider.notifier);

      if (state.categories.isEmpty) {
        notifier.getCategories();
      }

      if (state.listing.isEmpty) {
        notifier.getListing();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Category and free-text search share one backend query param, so
  /// selecting a category clears the search box and vice versa.
  void _onCategorySelected(String categoryId) {
    final next = _selectedCategoryId == categoryId ? null : categoryId;
    setState(() => _selectedCategoryId = next);
    _debounce?.cancel();
    _searchController.clear();
    ref.read(servicesNotiferProvider.notifier).filterByCategory(next);
  }

  void _onSearchChanged(String value) {
    if (_selectedCategoryId != null) {
      setState(() => _selectedCategoryId = null);
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = value.trim();
      ref.read(servicesNotiferProvider.notifier).getListing(
            name: query.isEmpty ? null : query,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbar: CustomAppBar(
        title: context.l10n.services,
        showBackButton: false,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          right: 10.w,
          bottom: 10.h,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: SearchTextField(
                    hintText: context.l10n.search,
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                // 10.horizontalSpace,
                // const FiltersWidget(),
              ],
            ),
          ),
          20.verticalSpace,
          Categories(
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: _onCategorySelected,
          ),
          20.verticalSpace,
          const SecondaryListingView(),
        ],
      ),
    );
  }
}
