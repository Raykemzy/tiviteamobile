import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/const/app_colors.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/features/services/model/bank_model.dart';
import 'package:tivi_tea/gen/assets.gen.dart';

class BankListDropdown extends ConsumerStatefulWidget {
  final List<BankModel> banks;
  final void Function(BankModel) onItemSelected;
  const BankListDropdown({
    super.key,
    required this.banks,
    required this.onItemSelected,
  });

  @override
  ConsumerState<BankListDropdown> createState() => _BankListDropdownState();
}

class _BankListDropdownState extends ConsumerState<BankListDropdown> {
  final _searchController = TextEditingController();
  String initialText = 'Select Bank';
  bool isExpanded = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// The list runs to hundreds of banks, so it is unusable without a filter.
  List<BankModel> get _filteredBanks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.banks;
    return widget.banks
        .where((bank) => (bank.name ?? '').toLowerCase().contains(query))
        .toList();
  }

  void _toggle() {
    isExpanded = !isExpanded;
    if (!isExpanded) {
      _searchController.clear();
      _query = '';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final banks = _filteredBanks;

    return AnimatedContainer(
      height: isExpanded ? 340.h : 70,
      width: context.width,
      clipBehavior: Clip.hardEdge,
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFE6E6EE),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggle,
            child: Row(
              children: [
                AppSvgWidget(
                  path: Assets.svgs.box.path,
                  color: const Color(0xFF77797D),
                ),
                10.horizontalSpace,
                Expanded(
                  child: Text(
                    initialText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(CupertinoIcons.chevron_down),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            12.verticalSpace,
            SizedBox(
              height: 40.h,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search banks',
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF77797D),
                  ),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    size: 18,
                    color: Color(0xFF77797D),
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : InkWell(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          child: const Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 18,
                            color: Color(0xFF77797D),
                          ),
                        ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE6E6EE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE6E6EE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.deepBlue),
                  ),
                ),
              ),
            ),
            10.verticalSpace,
            Expanded(
              child: banks.isEmpty
                  ? Center(
                      child: Text(
                        'No bank matches "${_query.trim()}"',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF77797D),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: banks.length,
                      itemBuilder: (context, i) => InkWell(
                        onTap: () {
                          widget.onItemSelected(banks[i]);
                          initialText = banks[i].name ?? '';
                          _searchController.clear();
                          _query = '';
                          isExpanded = false;
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(banks[i].name ?? ''),
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
