import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/core/utils/validators.dart';

void main() {
  group('Validators.phone', () {
    final validate = Validators.phone();

    for (final number in <String>[
      '08012345678', // MTN  — rejected by the old pattern
      '08155450066', // Glo  — rejected by the old pattern
      '08035551234',
      '09012345678',
      '07012345678',
      '8012345678',
      '+2348012345678',
      '2348012345678',
      '+234 801 234 5678',
      '0803-555-1234',
    ]) {
      test('accepts $number', () => expect(validate(number), isNull));
    }

    for (final number in <String>[
      '0601234567',
      '0801234567', // one digit short
      '080123456789', // one digit long
      'not-a-number',
      '',
    ]) {
      test('rejects $number', () => expect(validate(number), isNotNull));
    }
  });
}
