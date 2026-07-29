import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.content,
    super.key,
    this.title,
    this.height,
    this.width,
    this.subtitle,
    this.onExitTap,
    this.cancelPadding,
    this.titleWidget,
    this.padding,
    this.hasHeaders = true,
    this.showButton,
    this.onButtonPressed,
    this.maxHeightFactor = .95,
  });
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget content;
  final double? height;
  final double? width;
  final GestureTapCallback? onExitTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? cancelPadding;
  final bool hasHeaders;
  final bool? showButton;
  final VoidCallback? onButtonPressed;

  /// Share of the screen height the sheet may grow to before its content
  /// starts scrolling. Long forms should pass something well under 1 so the
  /// sheet still reads as a sheet rather than a full page.
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ColorFilter.mode(
        Colors.black.withValues(alpha: 0.2),
        BlendMode.srcOver,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
          minHeight: 100,
          minWidth: width ?? MediaQuery.of(context).size.width,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        padding: padding ?? const EdgeInsets.all(20),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title ?? '',
                      style: context.theme.textTheme.titleSmall,
                    ),
                    10.horizontalSpace,
                    if(!(showButton ?? false)) InkWell(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
                30.verticalSpace,
                Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: content,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
