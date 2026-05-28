import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tivi_tea/core/config/extensions/build_context_extensions.dart';
import 'package:tivi_tea/core/router/app_routes.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/core/utils/validators.dart';
import 'package:tivi_tea/features/common/app_appbar.dart';
import 'package:tivi_tea/features/common/app_button.dart';
import 'package:tivi_tea/features/common/app_scaffold.dart';
import 'package:tivi_tea/features/common/app_text_field.dart';
import 'package:tivi_tea/features/contact_us/view_model/contact_us_notifier.dart';
import 'package:tivi_tea/features/profile/view_model/user_notifier.dart';

class ContactUsView extends ConsumerStatefulWidget {
  const ContactUsView({super.key});

  @override
  ConsumerState<ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends ConsumerState<ContactUsView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(userNotifierProvider);
    _nameController = TextEditingController(
      text: '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
    );
    _emailController = TextEditingController(text: user.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appbar: const CustomAppBar(
        title: 'Contact Us',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Enter your name',
                validateFunction: Validators.notEmpty(),
              ),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'Enter your email',
                validateFunction: Validators.email(),
              ),
              AppTextField(
                controller: _subjectController,
                label: 'Subject',
                hintText: 'What is this about? (optional)',
              ),
              AppTextField(
                controller: _messageController,
                label: 'Message',
                hintText: 'Tell us how we can help you',
                maxLines: 5,
                validateFunction: Validators.notEmpty(),
              ),
              SizedBox(height: 32.h),
              Consumer(
                builder: (context, ref, _) {
                  final isLoading = ref.watch(contactUsNotifierProvider
                          .select((s) => s.loadState)) ==
                      LoadState.loading;
                  return AppButton(
                    buttonText: 'Send Message',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(contactUsNotifierProvider.notifier).submit(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          subject: _subjectController.text.trim(),
          message: _messageController.text.trim(),
          onSuccess: () {
            if (!mounted) return;
            context.showSuccess('Message sent! We\'ll get back to you soon.');
            context.go(AppRoutes.homeView);
          },
          onError: (msg) {
            if (!mounted) return;
            context.showError(msg);
          },
        );
  }
}
