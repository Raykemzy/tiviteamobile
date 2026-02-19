import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/utils/image_picker_notifier.dart';
import 'package:tivi_tea/core/utils/validators.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/add_marketplace_item_condition_price_section.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/add_marketplace_item_details_section.dart';
import 'package:tivi_tea/features/marketplace/view/widgets/add_marketplace_item_images_section.dart';
import 'package:tivi_tea/features/marketplace/view_model/owner_marketplace_notifier.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class AddMarketplaceItemView extends ConsumerStatefulWidget {
  const AddMarketplaceItemView({super.key});

  @override
  ConsumerState<AddMarketplaceItemView> createState() =>
      _AddMarketplaceItemViewState();
}

class _AddMarketplaceItemViewState
    extends ConsumerState<AddMarketplaceItemView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedCondition;

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _pickupLocationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Add Item',
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
                AddMarketplaceItemDetailsSection(
                  nameController: _nameController,
                  shortDescriptionController: _shortDescriptionController,
                  addressController: _pickupLocationController,
                  nameValidator: Validators.notEmpty(),
                  descriptionValidator: Validators.notEmpty(),
                  addressValidator: Validators.notEmpty(),
                ),
                SizedBox(height: 24.h),
                const AddMarketplaceItemImagesSection(),
                SizedBox(height: 24.h),
                AddMarketplaceItemConditionPriceSection(
                  selectedCondition: _selectedCondition,
                  onConditionSelected: (value) =>
                      setState(() => _selectedCondition = value),
                  priceController: _priceController,
                  priceValidator: Validators.positiveNumber(
                    'Please enter a price',
                    'Please enter a valid price',
                  ),
                ),
                SizedBox(height: 40.h),
                Center(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final createLoadState = ref
                          .watch(ownerMarketplaceNotifierProvider)
                          .createLoadState;
                      final isLoading = createLoadState == LoadState.loading;
                      return AppButton(
                        isLoading: isLoading,
                        buttonText: context.l10n.saveAndPublish,
                        onPressed: isLoading
                            ? null
                            : () => _submitItem(ref, context, inStock: true),
                      );
                    },
                  ),
                ),
                // SizedBox(height: 12.h),
                // Center(
                //   child: Consumer(
                //     builder: (context, ref, _) {
                //       final state = ref.watch(ownerMarketplaceNotifierProvider);
                //       final createLoadState = state.createLoadState;
                //       final isLoading = createLoadState == LoadState.loading;
                //       return AppButton(
                //         isLoading: isLoading,
                //         buttonText: context.l10n.saveToDraft,
                //         backgroundColor: Colors.white,
                //         textColor: context.theme.primaryColor,
                //         borderColor: context.theme.primaryColor,
                //         onPressed: isLoading
                //             ? null
                //             : () => _submitItem(ref, context, inStock: false),
                //       );
                //     },
                //   ),
                // ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitItem(
    WidgetRef ref,
    BuildContext context, {
    required bool inStock,
  }) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCondition == null || _selectedCondition!.isEmpty) {
      context.showError('Please select a condition');
      return;
    }

    final name = _nameController.text.trim();
    final description = _shortDescriptionController.text.trim();
    final price = num.parse(_priceController.text.trim());
    final pickUpAddress = _pickupLocationController.text.trim();
    final condition = _selectedCondition!;

    final images = ref.read(imagePickerNotifierProvider);
    final notifier = ref.read(ownerMarketplaceNotifierProvider.notifier);
    notifier.createMarketplaceItem(
      name: name,
      description: description,
      price: price,
      inStock: inStock,
      images: images,
      category: '',
      quantity: 1,
      pickUpAddress: pickUpAddress,
      condition: condition,
      onSuccess: (message) {
        ref.read(imagePickerNotifierProvider.notifier).clearImages();
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
