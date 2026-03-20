import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/search_text_field.dart';
import 'package:tivi_tea/features/home/model/client/category_response_model.dart';
import 'package:tivi_tea/features/home/view/widgets/category_section.dart';
import 'package:tivi_tea/features/home/view/widgets/secondary_listing_widget.dart';
import 'package:tivi_tea/features/services/view_model/services_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class AllListingsView extends StatefulWidget {
  const AllListingsView({super.key});

  @override
  State<AllListingsView> createState() => _AllListingsViewState();
}

class _AllListingsViewState extends State<AllListingsView> {
  String? _selectedCategoryId;

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
                  child: SearchTextField(hintText: context.l10n.search),
                ),
                // 10.horizontalSpace,
                // const FiltersWidget(),
              ],
            ),
          ),
          20.verticalSpace,
          Categories(
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (categoryId) {
              setState(() {
                _selectedCategoryId =
                    _selectedCategoryId == categoryId ? null : categoryId;
              });
            },
          ),
          20.verticalSpace,
          SecondaryListingView(selectedCategoryId: _selectedCategoryId),
        ],
      ),
    );
  }
}

class CategoryList extends ConsumerStatefulWidget {
  const CategoryList({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  @override
  ConsumerState<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(
      servicesNotiferProvider.select((value) => value.categories),
    );
    return Container(
      height: 40.h,
      margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
      child: AdaptiveScrollbar(
        width: 8,
        sliderHeight: 80,
        controller: _scrollController,
        position: ScrollbarPosition.bottom,
        underColor: const Color(0xFFC4C4CC),
        sliderDefaultColor: context.theme.primaryColor,
        underSpacing: EdgeInsets.only(top: 18.w, right: 20.h),
        sliderSpacing: EdgeInsets.zero,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (ctx, i) => 10.horizontalSpace,
          itemBuilder: (ctx, i) {
            final category = categories[i];
            final bool isSelected = widget.selectedCategoryId == category.id;
            return GestureDetector(
              onTap: () => _selectCategory(category),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 5.h,
                ),
                child: Text(
                  category.name ?? '',
                  style: context.theme.textTheme.labelMedium?.copyWith(
                    color: isSelected ? Colors.black : const Color(0xFF737380),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectCategory(CategoryResponseModel category) {
    final categoryId = category.id;
    if (categoryId == null) {
      return;
    }
    widget.onCategorySelected(categoryId);
  }
}
