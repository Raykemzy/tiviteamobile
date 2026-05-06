import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/const/artisan_services.dart';
import 'package:tivi_tea/core/theme/extensions/theme_extensions.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/utils/validators.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_country_selector.dart';
import 'package:tivi_tea/features/common/app_dropdown.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/profile/model/create_other_entity_account_request_body.dart';
import 'package:tivi_tea/features/profile/view_model/profile_notifer.dart';
import 'package:tivi_tea/models/address_model.dart';
import 'package:tivi_tea/models/enums/enums.dart';

class CreateOtherEntityAccountSheet extends ConsumerStatefulWidget {
  const CreateOtherEntityAccountSheet({
    super.key,
    required this.entityType,
  });

  final EntityType entityType;

  @override
  ConsumerState<CreateOtherEntityAccountSheet> createState() =>
      _CreateOtherEntityAccountSheetState();
}

class _CreateOtherEntityAccountSheetState
    extends ConsumerState<CreateOtherEntityAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(text: 'Nigeria');
  final _postalCodeController = TextEditingController();
  final _summaryController = TextEditingController();

  String? _selectedService;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadState = ref.watch(
      profileNotiferProvider.select(
        (value) => value.createOtherEntityAccountLoadState,
      ),
    );
    final isLoading = loadState == LoadState.loading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provide the service and location details for your artisan account.',
            style: context.theme.textTheme.displaySmall?.copyWith(
              color: const Color(0xFF737380),
            ),
          ),
          20.verticalSpace,
          Text(
            'Service type',
            style: context.theme.textTheme.labelMedium,
          ),
          10.verticalSpace,
          AppDropdown<String>(
            items: ArtisanServices.services,
            onItemSelected: (value) {
              _selectedService = value;
            },
          ),
          20.verticalSpace,
          AppTextField(
            controller: _streetController,
            label: 'Street address',
            hintText: '8, Alli street',
            validateFunction: Validators.notEmpty(),
          ),
          AppTextField(
            controller: _cityController,
            label: 'City',
            hintText: 'Akowonjo',
            validateFunction: Validators.notEmpty(),
          ),
          AppTextField(
            controller: _stateController,
            label: 'State',
            hintText: 'Lagos',
            validateFunction: Validators.notEmpty(),
          ),
          AppCountrySelector(
            controller: _countryController,
            validateFunction: Validators.notEmpty(),
          ),
          AppTextField(
            controller: _postalCodeController,
            label: 'Postal code',
            hintText: '10011',
            validateFunction: Validators.notEmpty(),
          ),
          AppTextField(
            controller: _summaryController,
            label: 'Summary',
            hintText: 'Optional short description',
            maxLines: 4,
            minLines: 4,
            textCapitalization: TextCapitalization.sentences,
            padding: const SizedBox(height: 32),
          ),
          AppButton(
            buttonText: 'Create Artisan Account',
            isLoading: isLoading,
            onPressed: () => _submit(context),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    if (!formIsValid) {
      return;
    }
    if (_selectedService == null) {
      context.showError('Please select a service type.');
      return;
    }

    final request = CreateOtherEntityAccountRequestBody(
      entityType: widget.entityType,
      serviceType: _selectedService!.trim().toLowerCase().replaceAll(' ', '_'),
      address: Address(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
      ),
      summary: _summaryController.text.trim(),
    );

    ref.read(profileNotiferProvider.notifier).createOtherEntityAccount(
      request,
      onSuccess: () {
        if (!mounted) return;
        context.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.showSuccess('Artisan account created successfully.');
        });
      },
      onError: (message) {
        if (!mounted) return;
        context.showError(message);
      },
    );
  }
}
