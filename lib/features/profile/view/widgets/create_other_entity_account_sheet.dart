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
import 'package:tivi_tea/features/common/app_phone_text_field.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/profile/model/create_other_entity_account_request_body.dart';
import 'package:tivi_tea/features/profile/view_model/profile_notifer.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';
import 'package:tivi_tea/models/address_model.dart';
import 'package:tivi_tea/models/enums/enums.dart';
import 'package:tivi_tea/models/user_model.dart';

/// Collects the details needed to create an entity the user doesn't own yet.
///
/// The form adapts to [entityType]: artisan asks for a service type, partner
/// for business details, client for nothing beyond the address.
///
/// [onCreated] fires after a successful create. The account switcher uses it
/// to switch straight into the new entity so the user only makes one choice.
class CreateOtherEntityAccountSheet extends ConsumerStatefulWidget {
  const CreateOtherEntityAccountSheet({
    super.key,
    required this.entityType,
    this.onCreated,
  });

  final EntityType entityType;
  final VoidCallback? onCreated;

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

  // Artisan-only.
  final _summaryController = TextEditingController();
  String? _selectedService;

  // Partner-only.
  final _companyNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  String _alternatePhoneNumber = '';

  bool get _isArtisan => widget.entityType == EntityType.artisan;
  bool get _isPartner => widget.entityType == EntityType.partner;

  @override
  void initState() {
    super.initState();
    // The new entity belongs to the same person, so seed the address from the
    // one already on file. Every field stays editable — this is a starting
    // point, not a lock.
    final address = ref.read(userNotifierProvider).address;
    if (address == null) return;
    _streetController.text = address.street ?? '';
    _cityController.text = address.city ?? '';
    _stateController.text = address.state ?? '';
    _postalCodeController.text = address.postalCode ?? '';
    final country = address.country;
    if (country != null && country.isNotEmpty) {
      _countryController.text = country;
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _summaryController.dispose();
    _companyNameController.dispose();
    _businessTypeController.dispose();
    _businessDescriptionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  String get _intro {
    switch (widget.entityType) {
      case EntityType.artisan:
        return 'Provide the service and location details for your artisan '
            'account.';
      case EntityType.partner:
        return 'Provide your business and location details to start listing '
            'spaces and tools.';
      case EntityType.client:
        return 'Confirm your location to finish setting up your client '
            'account.';
    }
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
            _intro,
            style: context.theme.textTheme.displaySmall?.copyWith(
              color: const Color(0xFF737380),
            ),
          ),
          20.verticalSpace,
          if (_isArtisan) ...[
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
          ],
          if (_isPartner) ...[
            AppTextField(
              controller: _companyNameController,
              label: 'Business name',
              hintText: 'tiviTea Ventures',
              validateFunction: Validators.notEmpty(),
            ),
            AppTextField(
              controller: _businessTypeController,
              label: 'Business type',
              hintText: 'Registered or Individual',
              validateFunction: Validators.notEmpty(),
            ),
            AppTextField(
              controller: _businessDescriptionController,
              label: 'Business description',
              hintText: 'What does your business do?',
              maxLines: 4,
              minLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validateFunction: Validators.notEmpty(),
            ),
            AppTextField(
              controller: _websiteController,
              label: 'Website',
              hintText: 'Optional',
            ),
            AppPhoneTextField(
              label: 'Alternate phone number',
              hintText: 'Optional',
              onChanged: (phone) =>
                  _alternatePhoneNumber = phone.completeNumber,
            ),
            20.verticalSpace,
          ],
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
            padding: _isArtisan
                ? const SizedBox(height: 24)
                : const SizedBox(height: 32),
          ),
          if (_isArtisan)
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
            buttonText: 'Create ${widget.entityType.label} Account',
            isLoading: isLoading,
            onPressed: () => _submit(context),
          ),
        ],
      ),
    );
  }

  Address get _address => Address(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
      );

  /// Builds the entity-specific payload, or null when a non-form field (the
  /// service dropdown) hasn't been filled in.
  CreateOtherEntityAccountRequestBody? _buildRequest(BuildContext context) {
    switch (widget.entityType) {
      case EntityType.artisan:
        if (_selectedService == null) {
          context.showError('Please select a service type.');
          return null;
        }
        return CreateOtherEntityAccountRequestBody.artisan(
          address: _address,
          serviceType: _selectedService!.trim().toLowerCase().replaceAll(
                ' ',
                '_',
              ),
          summary: _summaryController.text.trim(),
        );
      case EntityType.partner:
        return CreateOtherEntityAccountRequestBody.partner(
          address: _address,
          companyName: _companyNameController.text.trim(),
          businessType: _businessTypeController.text.trim(),
          businessDescription: _businessDescriptionController.text.trim(),
          website: _websiteController.text.trim(),
          alternatePhoneNumber: _alternatePhoneNumber.trim(),
        );
      case EntityType.client:
        return CreateOtherEntityAccountRequestBody.client(address: _address);
    }
  }

  void _submit(BuildContext context) {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    if (!formIsValid) {
      return;
    }

    final request = _buildRequest(context);
    if (request == null) {
      return;
    }

    ref.read(profileNotiferProvider.notifier).createOtherEntityAccount(
      request,
      onSuccess: () {
        if (!mounted) return;
        final onCreated = widget.onCreated;
        if (onCreated != null) {
          // The caller owns what happens next (closing the sheet, switching
          // into the new entity), so don't pop out from under it.
          onCreated();
          return;
        }
        context.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.showSuccess(
            '${widget.entityType.label} account created successfully.',
          );
        });
      },
      onError: (message) {
        if (!mounted) return;
        context.showError(message);
      },
    );
  }
}
