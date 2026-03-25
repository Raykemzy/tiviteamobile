import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/widget/reusable_add_text_button.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_image_widget.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/marketplace/model/owner_marketplace_item_model.dart';
import 'package:tivi_tea/features/marketplace/view_model/owner_marketplace_notifier.dart';

class MyMarketplaceView extends ConsumerStatefulWidget {
  const MyMarketplaceView({super.key});

  @override
  ConsumerState<MyMarketplaceView> createState() => _MyMarketplaceViewState();
}

class _MyMarketplaceViewState extends ConsumerState<MyMarketplaceView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(ownerMarketplaceNotifierProvider.notifier)
          .getOwnersMarketPlaceItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ownerMarketplaceNotifierProvider);
    final items = state.items;
    final isLoading = state.loadState == LoadState.loading && items.isEmpty;
    final isError = state.loadState == LoadState.error && items.isEmpty;

    return AppScaffold(
      appbar: const CustomAppBar(
        showHamburgerMenu: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Marketplace',
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: context.theme.primaryColor,
                  ),
                ),
                ReusableAddTextButton(
                  onTap: () => context.push(
                    '${AppRoutes.profile}/${AppRoutes.myMarketplaceView}/${AppRoutes.addMarketplaceItemView}',
                  ),
                  title: 'Add Item',
                  color: const Color(0xFFE8E8EB),
                  fontColor: Colors.black,
                )
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (isError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage ?? 'Failed to load items'),
                        12.verticalSpace,
                        TextButton(
                          onPressed: () => ref
                              .read(ownerMarketplaceNotifierProvider.notifier)
                              .getOwnersMarketPlaceItems(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No items yet',
                      style: context.theme.textTheme.displaySmall,
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.only(bottom: 16.h),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => 10.verticalSpace,
                  itemBuilder: (_, i) => _MyMarketplaceItemWidget(
                    item: items[i],
                    isDeleting: state.deletingItemId == items[i].id,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MyMarketplaceItemWidget extends StatelessWidget {
  const _MyMarketplaceItemWidget({
    required this.item,
    this.isDeleting = false,
  });

  final OwnerMarketplaceItemModel item;
  final bool isDeleting;

  static const double _tileHeight = 145;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.images?.isNotEmpty == true ? item.images!.first : '';

    return IgnorePointer(
      ignoring: isDeleting,
      child: Opacity(
        opacity: isDeleting ? 0.6 : 1,
        child: Container(
          width: context.width,
          height: _tileHeight.h,
          margin: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.5,
              color: const Color(0xFFD8D8DD),
            ),
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: _tileHeight.w,
                    height: _tileHeight.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.sp),
                        bottomLeft: Radius.circular(8.sp),
                      ),
                      child: imageUrl.isEmpty
                          ? Container(
                              color: context.theme.dividerColor,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 32.sp,
                                color: Colors.grey,
                              ),
                            )
                          : AppImageWidget(
                              imagePath: imageUrl,
                              borderRadius: BorderRadius.zero,
                            ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _ItemDetails(item: item)),
                        _ItemActions(item: item),
                      ],
                    ),
                  ),
                ],
              ),
              if (isDeleting)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 28.w,
                        height: 28.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemDetails extends StatelessWidget {
  const _ItemDetails({required this.item});

  final OwnerMarketplaceItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name ?? 'Untitled',
            style: context.theme.textTheme.titleLarge?.copyWith(
              fontSize: 16.sp,
              color: context.theme.primaryColor,
            ),
          ),
          5.verticalSpace,
          Flexible(
            child: Text(
              item.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.theme.textTheme.labelMedium?.copyWith(
                fontSize: 9.8.sp,
                color: const Color(0xFF737380),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: context.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item.category != null && item.category!.isNotEmpty)
                  Text(
                    item.category!,
                    style: context.theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF737380),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                item.price.getCurrencyText(
                  style: context.theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemActions extends ConsumerWidget {
  const _ItemActions({required this.item});

  final OwnerMarketplaceItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () async {
              await context.push<bool>(
                '${AppRoutes.profile}/${AppRoutes.myMarketplaceView}/${AppRoutes.editMarketplaceItemView}',
                extra: item,
              );
            },
            icon: Icon(Icons.edit_outlined, size: 18.sp),
            label: const Text('Edit'),
          ),
          TextButton.icon(
            onPressed: item.id == null || item.id!.isEmpty
                ? null
                : () => _confirmDelete(context, ref, item),
            icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red),
            label: Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    OwnerMarketplaceItemModel item,
  ) async {
    final confirmed = await context.showCustomDialog<bool>(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Delete item?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Are you sure you want to delete "${item.name ?? 'this item'}"? This cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => context.pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    ref.read(ownerMarketplaceNotifierProvider.notifier).deleteMarketplaceItem(
          itemId: item.id!,
          onSuccess: (message) {
            if (context.mounted) context.showSuccess(message);
          },
          onError: (message) {
            if (context.mounted) context.showError(message);
          },
        );
  }
}
