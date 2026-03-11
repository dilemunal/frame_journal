enum TemplateFieldType {
  text,
  multiline,
  number,
  rating,
  boolean,
  geo,
  duration,
  select,
  chips,
  repeatGroup,
}

class TemplateField {
  const TemplateField({
    required this.key,
    required this.label,
    required this.type,
    this.options = const <String>[],
    this.max,
  });

  final String key;
  final String label;
  final TemplateFieldType type;

  /// Optional options for select-like fields.
  final List<String> options;

  /// Optional max value, e.g. for rating fields.
  final int? max;
}

class JournalTemplate {
  const JournalTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.iconEmoji,
    required this.version,
    required this.fields,
  });

  /// Stable identifier used in code and storage.
  final String id;

  /// Human readable name shown in the UI.
  final String name;

  /// Logical type key, e.g. `dive_log`, `water`, `tennis`.
  final String type;

  /// Emoji or short label used in UI bento cards.
  final String iconEmoji;

  final int version;

  final List<TemplateField> fields;
}

