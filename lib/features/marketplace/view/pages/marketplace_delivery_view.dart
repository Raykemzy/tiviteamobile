import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/marketplace/model/marketplace_cart_line.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_cart_notifier.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_delivery_address_provider.dart';
import 'package:tivi_tea/features/marketplace/view_model/marketplace_delivery_notifier.dart';

class MarketplaceDeliveryView extends ConsumerStatefulWidget {
  const MarketplaceDeliveryView({super.key});

  @override
  ConsumerState<MarketplaceDeliveryView> createState() =>
      _MarketplaceDeliveryViewState();
}

class _MarketplaceDeliveryViewState
    extends ConsumerState<MarketplaceDeliveryView> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(
      text: ref.read(marketplaceDeliveryAddressProvider),
    );
    _addressController.addListener(_onAddressChanged);
  }

  void _onAddressChanged() {
    ref.read(marketplaceDeliveryAddressProvider.notifier).state =
        _addressController.text;
  }

  @override
  void dispose() {
    _addressController.removeListener(_onAddressChanged);
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(marketplaceDeliverySelectionProvider);
    final notifier = ref.read(marketplaceDeliverySelectionProvider.notifier);
    final cartLines = ref.watch(marketplaceCartProvider).lines;
    final primary = context.theme.primaryColor;
    final pickupAddress = cartLines.firstListingAddress ?? '—';

    return AppScaffold(
      appbar: const CustomAppBar(title: 'Delivery'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              children: [
                RadioGroup<MarketplaceDeliveryOption>(
                  groupValue: selected,
                  onChanged: (MarketplaceDeliveryOption? value) {
                    if (value != null) notifier.select(value);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DeliveryOptionCard(
                        option: MarketplaceDeliveryOption.deliverToMe,
                        selected: selected,
                        primary: primary,
                        onSelect: notifier.select,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: _addressController,
                              hintText: 'Enter delivery address here',
                              maxLines: 3,
                              padding: const SizedBox.shrink(),
                              labelSpace: 0,
                            ),
                            12.verticalSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Additional cost',
                                  style: context.theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF737380),
                                    fontSize: 13.sp,
                                  ),
                                ),
                                MarketplaceDeliveryOption.deliverToMe.fee
                                    .getCurrencyText(
                                  style: context.theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF333333),
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      30.verticalSpace,
                      _DeliveryOptionCard(
                        option: MarketplaceDeliveryOption.pickup,
                        selected: selected,
                        primary: primary,
                        onSelect: notifier.select,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 22.sp,
                              color: const Color(0xFF737380),
                            ),
                            10.horizontalSpace,
                            Expanded(
                              child: Text(
                                pickupAddress,
                                style: context.theme.textTheme.bodyMedium
                                    ?.copyWith(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF333333),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: AppButton(
              buttonText: 'Continue to summary',
              onPressed: () => context.push(
                '${AppRoutes.servicesView}/${AppRoutes.marketplaceOrderSummaryView}',
              ),
            ),
          ),
          16.verticalSpace,
        ],
      ),
    );
  }
}

class _DeliveryOptionCard extends StatelessWidget {
  const _DeliveryOptionCard({
    required this.option,
    required this.selected,
    required this.primary,
    required this.onSelect,
    required this.child,
  });

  final MarketplaceDeliveryOption option;
  final MarketplaceDeliveryOption selected;
  final Color primary;
  final void Function(MarketplaceDeliveryOption) onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == option;
    final borderColor = isSelected ? primary : const Color(0xFFD8D8DD);
    final borderWidth = 0.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(option),
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 8.w, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        option.title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B909A),
                          height: 1.2,
                        ),
                      ),
                    ),
                    Radio<MarketplaceDeliveryOption>(
                      value: option,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return primary;
                        }
                        return const Color(0xFF737380);
                      }),
                      innerRadius: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return 6.r;
                        }
                        return 0;
                      }),

                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: const Color(0xFFD8D8DD),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
