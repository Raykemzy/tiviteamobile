import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tivi_tea/core/const/app_colors.dart';
import 'package:tivi_tea/core/const/countries.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';

class AppCountrySelector extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<Country>? onCountrySelected;
  final FormFieldValidator<String>? validateFunction;
  final String? initialValue;
  final String? initialCountryCode;
  final bool readOnly;
  const AppCountrySelector({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onCountrySelected,
    this.validateFunction,
    this.initialValue,
    this.initialCountryCode,
    this.readOnly = false,
  });

  @override
  State<AppCountrySelector> createState() => _AppCountrySelectorState();
}

class _AppCountrySelectorState extends State<AppCountrySelector> {
  static const Set<String> _missingFlagCodes = {
    'KI',
    'XK',
    'MH',
    'NR',
    'PS',
    'SS',
    'TV',
    'VA',
  };

  late final TextEditingController _textController;
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _selectedCountry = _resolveInitialCountry();
    if (_textController.text.trim().isEmpty && _selectedCountry != null) {
      _textController.text = _selectedCountry!.name;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

  Country _defaultCountry() {
    return countries.firstWhere(
      (country) => country.code == 'NG',
      orElse: () => countries.first,
    );
  }

  Country? _findCountryByName(String name) {
    final query = name.trim().toLowerCase();
    if (query.isEmpty) return null;
    for (final country in countries) {
      if (country.name.toLowerCase() == query) {
        return country;
      }
    }
    return null;
  }

  Country? _resolveInitialCountry() {
    final existingTextMatch = _findCountryByName(_textController.text);
    if (existingTextMatch != null) {
      return existingTextMatch;
    }

    if (widget.initialCountryCode != null &&
        widget.initialCountryCode!.trim().isNotEmpty) {
      final code = widget.initialCountryCode!.trim().toUpperCase();
      for (final country in countries) {
        if (country.code == code) {
          return country;
        }
      }
    }

    if (widget.initialValue != null && widget.initialValue!.trim().isNotEmpty) {
      final valueMatch = _findCountryByName(widget.initialValue!);
      if (valueMatch != null) {
        return valueMatch;
      }
    }

    return _defaultCountry();
  }

  String _flagPath(Country country) {
    final mappedCode = switch (country.code) {
      'DO' => 'DOX',
      'IN' => 'INX',
      'IS' => 'ISX',
      _ => country.code,
    };
    final code = _missingFlagCodes.contains(country.code) ? 'WW' : mappedCode;
    return 'assets/icons/flags/$code.svg';
  }

  @override
  Widget build(BuildContext context) {
    final selectedCountry = _selectedCountry ?? _defaultCountry();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label ?? context.l10n.country,
          style: context.theme.textTheme.labelMedium,
        ),
        SizedBox(height: 10.h),
        Autocomplete<Country>(
          initialValue: TextEditingValue(text: _textController.text),
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim().toLowerCase();
            if (query.isEmpty) {
              return countries;
            }
            return countries.where(
              (country) => country.name.toLowerCase().contains(query),
            );
          },
          displayStringForOption: (country) => country.name,
          onSelected: (country) {
            setState(() => _selectedCountry = country);
            _textController.text = country.name;
            widget.onCountrySelected?.call(country);
            widget.onChanged?.call(country.name);
          },
          fieldViewBuilder: (
            context,
            textEditingController,
            focusNode,
            onFieldSubmitted,
          ) {
            if (!identical(textEditingController, _textController)) {
              textEditingController.value = _textController.value;
            }
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              readOnly: widget.readOnly,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: widget.validateFunction,
              style: context.theme.textTheme.displaySmall,
              onFieldSubmitted: (_) => onFieldSubmitted(),
              onChanged: (value) {
                if (!identical(textEditingController, _textController)) {
                  _textController.value = textEditingController.value;
                }
                widget.onChanged?.call(value);
                final matchedCountry = _findCountryByName(value);
                if (matchedCountry != null &&
                    matchedCountry.code != _selectedCountry?.code) {
                  setState(() => _selectedCountry = matchedCountry);
                  widget.onCountrySelected?.call(matchedCountry);
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                isDense: true,
                errorStyle: const TextStyle(fontSize: 0, height: -30),
                hintText: widget.hintText ?? context.l10n.country,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF737380),
                ),
                prefixIcon: SizedBox(
                  width: 82.w,
                  child: Row(
                    children: [
                      SizedBox(width: 10.w),
                      SvgPicture.asset(
                        _flagPath(selectedCountry),
                        width: 22.w,
                        height: 16.h,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 10.w),
                      const Icon(Icons.keyboard_arrow_down, size: 20),
                      SizedBox(width: 8.w),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Color(0xFFD8D8DD),
                      ),
                    ],
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.danger),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.danger),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD8D8DD)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD8D8DD)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD8D8DD)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.theme.primaryColor),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final optionList = options.toList();
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.white,
                elevation: 3,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 260.h,
                    maxWidth: MediaQuery.of(context).size.width - 32.w,
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shrinkWrap: true,
                    itemCount: optionList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final country = optionList[index];
                      return InkWell(
                        onTap: () => onSelected(country),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                _flagPath(country),
                                width: 22.w,
                                height: 16.h,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  country.name,
                                  style: context.theme.textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        24.verticalSpace,
      ],
    );
  }
}
