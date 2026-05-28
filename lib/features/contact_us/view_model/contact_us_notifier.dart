import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/config/dio_config.dart';
import 'package:tivi_tea/core/utils/enums.dart';
import 'package:tivi_tea/features/contact_us/model/contact_us_request_body.dart';
import 'package:tivi_tea/features/contact_us/view_model/contact_us_state.dart';
import 'package:tivi_tea/repositories/contact_us/contact_us_repo.dart';

part 'contact_us_notifier.g.dart';

@riverpod
class ContactUsNotifier extends _$ContactUsNotifier {
  late final ContactUsRepo _repo;

  @override
  ContactUsState build() {
    _repo = ContactUsRepo(restClient: ref.read(restClient));
    return ContactUsState.initial();
  }

  Future<void> submit({
    required String name,
    required String email,
    required String subject,
    required String message,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    state = state.copyWith(loadState: LoadState.loading, errorMessage: null);
    try {
      final body = ContactUsRequestBody(
        name: name,
        email: email,
        subject: subject,
        message: message,
      );
      final response = await _repo.contactUs(body);
      if (!response.isSuccess()) {
        throw response.error?.message ??
            response.message ??
            'Failed to send message. Please try again.';
      }
      state = state.copyWith(loadState: LoadState.success);
      onSuccess();
    } catch (e) {
      final msg = e.toString();
      state = state.copyWith(loadState: LoadState.error, errorMessage: msg);
      onError(msg);
    }
  }
}
