import 'package:tivi_tea/core/config/extensions/string_extensions.dart';
import 'package:tivi_tea/features/artisans/model/artisan_response_model.dart';

extension ArtisanResponseModelExt on ArtisanResponseModel {
  String get fullName {
    final first = user?.firstName?.trim() ?? '';
    final last = user?.lastName?.trim() ?? '';
    final name = '$first $last'.trim();
    return name.isNotEmpty ? name : 'Unknown Artisan';
  }

  String get serviceTypeDisplay {
    final t = serviceType?.trim();
    if (t != null && t.isNotEmpty) return t.capiTalizeFirst;
    return serviceTypeSummary?.trim().isNotEmpty == true
        ? serviceTypeSummary!
        : 'Artisan';
  }

  /// Optional summary text from meta or serviceTypeSummary.
  String? get summaryText {
    if (meta != null && meta!['summary'] != null) {
      return meta!['summary'] as String?;
    }
    return serviceTypeSummary;
  }
}
