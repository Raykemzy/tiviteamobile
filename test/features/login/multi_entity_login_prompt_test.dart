import 'package:flutter_test/flutter_test.dart';
import 'package:tivi_tea/features/login/model/general/multi_entity_login_prompt.dart';
import 'package:tivi_tea/models/enums/enums.dart';

void main() {
  group('MultiEntityLoginPrompt.tryParse', () {
    test('returns null for ordinary login failures', () {
      expect(MultiEntityLoginPrompt.tryParse('Invalid credentials'), isNull);
      expect(MultiEntityLoginPrompt.tryParse('User not verified'), isNull);
      expect(MultiEntityLoginPrompt.tryParse(null), isNull);
      expect(MultiEntityLoginPrompt.tryParse(''), isNull);
    });

    test('recognises the "input entity" wording', () {
      final prompt = MultiEntityLoginPrompt.tryParse('Please input entity');
      expect(prompt, isNotNull);
    });

    test('recognises "multiple accounts found"', () {
      expect(
        MultiEntityLoginPrompt.tryParse('multiple accounts found'),
        isNotNull,
      );
    });

    test('pulls the named entities out of the message', () {
      final prompt = MultiEntityLoginPrompt.tryParse(
        'Please input entity. Available: partner, client',
      );
      expect(prompt!.options, [EntityType.partner, EntityType.client]);
    });

    test('offers every entity when the message names none', () {
      final prompt = MultiEntityLoginPrompt.tryParse('Please input entity');
      expect(prompt!.options, EntityType.values);
    });

    test('is case insensitive', () {
      final prompt = MultiEntityLoginPrompt.tryParse(
        'PLEASE INPUT ENTITY: ARTISAN',
      );
      expect(prompt!.options, [EntityType.artisan]);
    });

    test('does not fire on unrelated messages mentioning entity', () {
      expect(
        MultiEntityLoginPrompt.tryParse('Entity not found'),
        isNull,
      );
    });
  });
}
