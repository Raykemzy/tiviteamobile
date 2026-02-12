import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/const/artisan_services.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/utils/validators.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_country_selector.dart';
import 'package:tivi_tea/features/common/app_dropdown.dart';
import 'package:tivi_tea/features/common/app_phone_text_field.dart';
import 'package:tivi_tea/features/common/app_svg_widget.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/registration/model/artisan/artisan_sign_up_request_body.dart';
import 'package:tivi_tea/features/registration/view/widgets/form_section_header.dart';
import 'package:tivi_tea/features/registration/view/widgets/registration_appbar.dart';
import 'package:tivi_tea/features/registration/view/widgets/registration_scaffold.dart';
import 'package:tivi_tea/features/registration/view_model/service_provider/registration_notifier.dart';
import 'package:tivi_tea/gen/assets.gen.dart';
import 'package:tivi_tea/l10n/extensions/l10n_extensions.dart';
import 'package:tivi_tea/models/address_model.dart';

class CreateArtisanAccountView extends StatefulWidget {
  const CreateArtisanAccountView({super.key});

  @override
  State<CreateArtisanAccountView> createState() =>
      _CreateArtisanAccountViewState();
}

class _CreateArtisanAccountViewState extends State<CreateArtisanAccountView> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateOrProvinceController =
      TextEditingController();
  final TextEditingController postalOrZipCodeController =
      TextEditingController();
  final TextEditingController serviceOtherController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool obscurePass = true;
  bool obscureConfirmPass = true;

  final _formKey = GlobalKey<FormState>();
  bool isEnabled = false;
  String phoneNumber = "";
  String? selectedService;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    stateOrProvinceController.dispose();
    postalOrZipCodeController.dispose();
    serviceOtherController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    _formKey.currentState?.dispose();
    super.dispose();
  }

  void _obscurePass() {
    obscurePass = !obscurePass;
    setState(() {});
  }

  void _obscureConfirmPass() {
    obscureConfirmPass = !obscureConfirmPass;
    setState(() {});
  }

  bool _isValidIfFilled(String value, String? Function(String?) validator) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    return validator(trimmed) == null;
  }

  void _updateFormState() {
    final hasAllRequiredValues = firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        phoneNumber.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        countryController.text.trim().isNotEmpty &&
        stateOrProvinceController.text.trim().isNotEmpty &&
        postalOrZipCodeController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        confirmPasswordController.text.trim().isNotEmpty &&
        selectedService != null;

    final areFilledFieldsValid =
        _isValidIfFilled(firstNameController.text, Validators.name()) &&
            _isValidIfFilled(lastNameController.text, Validators.name()) &&
            _isValidIfFilled(emailController.text, Validators.email()) &&
            _isValidIfFilled(addressController.text, Validators.notEmpty()) &&
            _isValidIfFilled(cityController.text, Validators.notEmpty()) &&
            _isValidIfFilled(countryController.text, Validators.notEmpty()) &&
            _isValidIfFilled(
              stateOrProvinceController.text,
              Validators.notEmpty(),
            ) &&
            _isValidIfFilled(
              postalOrZipCodeController.text,
              Validators.notEmpty(),
            ) &&
            _isValidIfFilled(
              confirmPasswordController.text,
              Validators.confirmPass(passwordController.text),
            );

    setState(() {
      isEnabled = hasAllRequiredValues && areFilledFieldsValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationScaffold(
      appbar: const RegistrationAppBar(
        headerSectionTitle: 'Artisan',
        headerSectionSubtitle:
            'Registration is quick and easy, Lets help you reach a wider audience today!',
      ),
      body: Form(
        key: _formKey,
        onChanged: _updateFormState,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Register as an Artisan',
                textAlign: TextAlign.center,
                style: context.theme.textTheme.displayLarge,
              ),
              10.verticalSpace,
              Text(
                'Provide correct information to setup your account',
                textAlign: TextAlign.center,
                style: context.theme.textTheme.displaySmall?.copyWith(
                  color: const Color(0xFF737380),
                ),
              ),
              20.verticalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormSectionHeader(title: context.l10n.personalInfo),
                  AppTextField(
                    controller: firstNameController,
                    validateFunction: Validators.name(),
                    label: context.l10n.firstName,
                    hintText: context.l10n.firstNameHintText,
                  ),
                  AppTextField(
                    controller: lastNameController,
                    validateFunction: Validators.name(),
                    label: context.l10n.lastName,
                    hintText: context.l10n.lastNameHintText,
                  ),
                  AppPhoneTextField(
                    label: context.l10n.phoneNumber,
                    hintText: context.l10n.phoneNumberHintText,
                    onChanged: (phone) {
                      phoneNumber = phone.completeNumber;
                      _updateFormState();
                    },
                  ),
                  AppTextField(
                    controller: emailController,
                    label: context.l10n.email,
                    hintText: context.l10n.emailHintText,
                    validateFunction: Validators.email(),
                    suffixIcon: AppSvgWidget(
                      path: Assets.svgs.envelope.path,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  FormSectionHeader(title: context.l10n.locationDetails),
                  AppTextField(
                    controller: addressController,
                    label: context.l10n.yourAddress,
                    hintText: context.l10n.yourAddressHintText,
                    validateFunction: Validators.notEmpty(),
                  ),
                  AppTextField(
                    controller: cityController,
                    label: context.l10n.city,
                    validateFunction: Validators.notEmpty(),
                  ),
                  AppCountrySelector(
                    controller: countryController,
                    validateFunction: Validators.notEmpty(),
                  ),
                  AppTextField(
                    controller: stateOrProvinceController,
                    label: context.l10n.stateOrProvince,
                    validateFunction: Validators.notEmpty(),
                  ),
                  AppTextField(
                    controller: postalOrZipCodeController,
                    label: context.l10n.postalOrZipCode,
                    validateFunction: Validators.notEmpty(),
                  ),
                  FormSectionHeader(title: context.l10n.accountInfo),
                  AppTextField(
                    controller: passwordController,
                    label: context.l10n.createPassword,
                    hintText: context.l10n.createPasswordHintText,
                    obscureText: obscurePass,
                    suffixIcon: InkWell(
                      onTap: _obscurePass,
                      child: AppSvgWidget(
                        path: obscurePass
                            ? Assets.svgs.eye.path
                            : Assets.svgs.eyeSlash.path,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                  AppTextField(
                    controller: confirmPasswordController,
                    label: context.l10n.confirmPassword,
                    hintText: context.l10n.confirmPasswordHintText,
                    obscureText: obscureConfirmPass,
                    suffixIcon: InkWell(
                      onTap: _obscureConfirmPass,
                      child: AppSvgWidget(
                        path: obscureConfirmPass
                            ? Assets.svgs.eye.path
                            : Assets.svgs.eyeSlash.path,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    validateFunction: Validators.confirmPass(
                      passwordController.text,
                    ),
                  ),
                  FormSectionHeader(title: context.l10n.serviceDetails),
                  Text(
                    context.l10n.selectTheServiceYouProvide,
                    style: context.theme.textTheme.bodyMedium,
                  ),
                  10.verticalSpace,
                  AppDropdown<String>(
                    items: ArtisanServices.services,
                    onItemSelected: (value) {
                      selectedService = value;
                      _updateFormState();
                    },
                  ),
                  20.verticalSpace,
                  AppTextField(
                    controller: serviceOtherController,
                    label: context.l10n.ifOtherPleaseSpecifyBelowOptional,
                    hintText: context.l10n.describesWhatYouDo,
                  ),
                  20.verticalSpace,
                  Center(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final loadState =
                            ref.watch(registrationNotifierProvider).loadState;
                        final isLoading = loadState == LoadState.loading;
                        return AppButton(
                          buttonText: context.l10n.continue_,
                          isEnabled: isEnabled,
                          isLoading: isLoading,
                          onPressed: () => _submit(ref),
                        );
                      },
                    ),
                  ),
                  10.verticalSpace,
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: context.l10n.alreadyHaveAccount,
                        style: context.theme.textTheme.displaySmall,
                        children: [
                          TextSpan(
                            text: context.l10n.login,
                            style:
                                context.theme.textTheme.displaySmall?.copyWith(
                              color: const Color(0xFFEC8305),
                              fontWeight: FontWeight.w700,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.push(AppRoutes.loginView),
                          ),
                        ],
                      ),
                    ),
                  ),
                  50.verticalSpace,
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submit(WidgetRef ref) {
    final serviceType = selectedService?.trim();
    final request = ArtisanSignUpRequestBody(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneNumber.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
      serviceType: serviceType?.toUpperCase().replaceAll(' ', '_'),
      summary: serviceOtherController.text.trim(),
      address: Address(
        street: addressController.text.trim(),
        city: cityController.text.trim(),
        state: stateOrProvinceController.text.trim(),
        country: countryController.text.trim(),
        postalCode: postalOrZipCodeController.text.trim(),
      ),
    );

    final notifier = ref.read(registrationNotifierProvider.notifier);
    notifier.signUpAsArtisan(
      request,
      onSuccess: (message) {
        context.showSuccess(message);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.pushReplacement(AppRoutes.loginView);
          }
        });
      },
      onError: (error) => context.showError(error),
    );
  }
}
