import 'package:tivi_tea/core/utils/enums.dart';

class ContactUsState {
  const ContactUsState({
    required this.loadState,
    this.errorMessage,
  });

  factory ContactUsState.initial() =>
      const ContactUsState(loadState: LoadState.idle);

  final LoadState loadState;
  final String? errorMessage;

  ContactUsState copyWith({
    LoadState? loadState,
    String? errorMessage,
  }) {
    return ContactUsState(
      loadState: loadState ?? this.loadState,
      errorMessage: errorMessage,
    );
  }
}
