import 'package:tivi_tea/models/enums/enums.dart';

/// Recognises the login failure that means "this account owns several
/// entities — say which one you're signing in as".
///
/// The backend's wording isn't pinned down (it was described only as an error
/// saying something like "input entity"), and it was later changed to list the
/// account's entities in the message. So match liberally on the phrasing and
/// pull out whichever entity names appear.
class MultiEntityLoginPrompt {
  const MultiEntityLoginPrompt({required this.options});

  /// Entities offered to the user. Falls back to all of them when the message
  /// doesn't name any — the backend rejects entities the account doesn't own,
  /// so a wrong guess surfaces as a normal error rather than a dead end.
  final List<EntityType> options;

  static const _entityNames = {
    'partner': EntityType.partner,
    'client': EntityType.client,
    'artisan': EntityType.artisan,
  };

  /// Returns a prompt when [message] looks like the multi-entity error, or
  /// null when it's an ordinary login failure.
  static MultiEntityLoginPrompt? tryParse(String? message) {
    if (message == null || message.isEmpty) return null;
    final text = message.toLowerCase();

    final looksLikePrompt = text.contains('input entity') ||
        text.contains('multiple accounts found') ||
        (text.contains('entity') &&
            (text.contains('multiple') ||
                text.contains('select') ||
                text.contains('choose') ||
                text.contains('specify')));
    if (!looksLikePrompt) return null;

    final named = <EntityType>[
      for (final entry in _entityNames.entries)
        if (text.contains(entry.key)) entry.value,
    ];

    return MultiEntityLoginPrompt(
      options: named.isEmpty ? EntityType.values.toList() : named,
    );
  }
}
