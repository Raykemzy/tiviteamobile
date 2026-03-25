import 'package:tivi_tea/core/config/extensions/data_type_extensions.dart';
import 'package:tivi_tea/features/home/model/general/listing_response_model.dart';

String formatMarketplaceNaira(num? amount) {
  if (amount == null) return '—';
  return '₦${amount.formatAmount}';
}

String? marketplaceSellerValue(ListingResponseModel item) {
  final u = item.user ?? item.partner?.user;
  if (u == null) return null;
  final name = '${u.firstName ?? ''} ${u.lastName ?? ''}'.trim();
  if (name.isNotEmpty) return name;
  final email = u.email?.trim();
  if (email != null && email.isNotEmpty) return email;
  return null;
}

String? marketplaceLocationValue(ListingResponseModel item) {
  final a = item.address?.trim();
  if (a == null || a.isEmpty) return null;
  return a;
}

int? marketplaceVisibleReviewCount(ListingResponseModel item) {
  final c = item.reviewCount;
  if (c == null || c <= 0) return null;
  return c;
}
