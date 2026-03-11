import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// In-memory registry that loads JSON template definitions from assets.
///
/// New templates can be added by dropping a new `.json` file under
/// `assets/templates/` and referencing it in the UI by its `type`.
class TemplateRegistry {
  TemplateRegistry._();

  static final TemplateRegistry instance = TemplateRegistry._();

  final Map<String, Map<String, dynamic>> _byType = {};
  bool _loaded = false;

  /// Ensures all template JSON files under `assets/templates/` are loaded.
  Future<void> ensureLoaded() async {
    if (_loaded) return;

    final manifestJson =
        await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest =
        json.decode(manifestJson) as Map<String, dynamic>;

    final templateAssetPaths = manifest.keys.where(
      (k) => k.startsWith('assets/templates/') && k.endsWith('.json'),
    );

    for (final path in templateAssetPaths) {
      final contents = await rootBundle.loadString(path);
      final Map<String, dynamic> data =
          json.decode(contents) as Map<String, dynamic>;

      final String type = (data['type'] as String?) ?? '';
      if (type.isEmpty) continue;
      _byType[type] = data;
    }

    _loaded = true;
  }

  /// Returns all known templates (after [ensureLoaded]).
  List<Map<String, dynamic>> get allTemplates =>
      _byType.values.toList(growable: false);

  /// Look up a template definition by its logical type, e.g. `dive_log`.
  Map<String, dynamic>? templateForType(String type) => _byType[type];
}

