import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/utils/validators.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/marketplace/model/owner_marketplace_item_model.dart';
import 'package:tivi_tea/features/marketplace/view_model/owner_marketplace_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class EditMarketplaceItemView extends ConsumerStatefulWidget {
  const EditMarketplaceItemView({super.key, required this.item});

  final OwnerMarketplaceItemModel item;

  @override
  ConsumerState<EditMarketplaceItemView> createState() =>
      _EditMarketplaceItemViewState();
}

class _EditMarketplaceItemViewState extends ConsumerState<EditMarketplaceItemView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late bool _inStock;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.price?.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.item.quantity?.toString() ?? '0',
    );
    _inStock = widget.item.inStock ?? true;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Edit Item',
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  widget.item.name ?? 'Untitled',
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18.sp,
                    color: context.theme.primaryColor,
                  ),
                ),
                if (widget.item.description != null &&
                    widget.item.description!.isNotEmpty) ...[
                  8.verticalSpace,
                  Text(
                    widget.item.description!,
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF737380),
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
                AppTextField(
                  controller: _priceController,
                  hintText: 'Price of item',
                  keyboardType: TextInputType.number,
                  validateFunction: Validators.positiveNumber(
                    'Please enter a price',
                    'Please enter a valid price',
                  ),
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  controller: _quantityController,
                  hintText: 'Quantity',
                  keyboardType: TextInputType.number,
                  validateFunction: Validators.positiveNumber(
                    'Please enter quantity',
                    'Please enter a valid quantity',
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      'In stock',
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: context.theme.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _inStock,
                      onChanged: (value) => setState(() => _inStock = value),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                Center(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final editLoadState =
                          ref.watch(ownerMarketplaceNotifierProvider).editLoadState;
                      final isLoading = editLoadState == LoadState.loading;
                      return AppButton(
                        isLoading: isLoading,
                        buttonText: context.l10n.save,
                        onPressed: isLoading ? null : _save,
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final itemId = widget.item.id;
    if (itemId == null || itemId.isEmpty) {
      context.showError('Invalid item');
      return;
    }

    final price = num.parse(_priceController.text.trim());
    final quantity = int.parse(_quantityController.text.trim());

    ref.read(ownerMarketplaceNotifierProvider.notifier).editMarketplaceItem(
          itemId: itemId,
          price: price,
          inStock: _inStock,
          quantity: quantity,
          onSuccess: (message) {
            if (context.mounted) {
              context.showSuccess(message);
              context.pop(true);
            }
          },
          onError: (message) {
            if (context.mounted) context.showError(message);
          },
        );
  }
}
