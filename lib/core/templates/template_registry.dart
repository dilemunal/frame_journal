import '../models/journal_template.dart';
import 'app_templates.dart';

/// In-memory registry backed by static [JournalTemplate] definitions.
///
/// This keeps templates type-safe and avoids runtime JSON parsing.
class TemplateRegistry {
  TemplateRegistry._()
      : _byType = {
          for (final template in appTemplates) template.type: template,
        };

  static final TemplateRegistry instance = TemplateRegistry._();

  final Map<String, JournalTemplate> _byType;

  /// Kept for API compatibility; static templates are always "loaded".
  Future<void> ensureLoaded() async {}

  List<JournalTemplate> get allTemplates =>
      _byType.values.toList(growable: false);

  JournalTemplate? templateForType(String type) => _byType[type];
}

