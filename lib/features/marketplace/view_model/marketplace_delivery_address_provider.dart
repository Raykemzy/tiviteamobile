import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Typed delivery address when "Deliver to me" is selected.
final marketplaceDeliveryAddressProvider = StateProvider<String>((ref) => '');
