import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';

const List<String> marketplaceConditionOptions = ['new', 'good', 'second-hand'];

class MarketplaceConditionDropdown extends StatelessWidget {
  const MarketplaceConditionDropdown({
    super.key,
    this.selectedCondition,
    required this.onSelected,
  });

  final String? selectedCondition;
  final void Function(String) onSelected;

  static List<String> get _displayOptions => marketplaceConditionOptions
      .map((e) =>
          e == 'second-hand' ? 'Second-hand' : '${e[0].toUpperCase()}${e.substring(1)}')
      .toList();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < marketplaceConditionOptions.length; i++)
                  ListTile(
                    title: Text(_displayOptions[i]),
                    onTap: () {
                      onSelected(marketplaceConditionOptions[i]);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: context.width,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE6E6EE)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCondition == null
                    ? 'Condition of item'
                    : _displayOptions[
                        marketplaceConditionOptions.indexOf(selectedCondition!)],
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color: selectedCondition == null
                      ? const Color(0xFF737380)
                      : null,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
