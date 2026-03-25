import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Last marketplace order id after POST `/listings/market-place/order` (for payment step).
final marketplacePendingOrderIdProvider = StateProvider<String?>((ref) => null);
