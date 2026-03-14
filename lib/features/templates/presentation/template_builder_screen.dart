import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/theme/app_theme.dart';

class TemplateBuilderScreen extends ConsumerStatefulWidget {
  const TemplateBuilderScreen({super.key});

  @override
  ConsumerState<TemplateBuilderScreen> createState() =>
      _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends ConsumerState<TemplateBuilderScreen> {
  final _nameController = TextEditingController();
  String _emoji = '📝';
  String _color = '#8FA5BA';
  final List<_FieldEdit> _fields = [];
  static const _fieldTypes = [
    'text',
    'long_text',
    'number',
    'slider',
    'select',
    'location',
    'photo',
    'weather',
    'tags',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şablon adı girin')),
      );
      return;
    }
    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final id = await db.into(db.journalTemplates).insert(
          JournalTemplatesCompanion.insert(
            name: name,
            icon: _emoji,
            color: _color,
            isDefault: const Value(false),
            createdAt: now,
          ),
        );
    for (var i = 0; i < _fields.length; i++) {
      final f = _fields[i];
      await db.into(db.templateFields).insert(
        TemplateFieldsCompanion.insert(
          templateId: id,
          label: f.label,
          fieldType: f.fieldType,
          options: f.options != null && f.options!.isNotEmpty
              ? Value(f.options)
              : const Value.absent(),
          isRequired: Value(f.isRequired),
          sortOrder: i,
          unit: f.unit != null && f.unit!.isNotEmpty
              ? Value(f.unit)
              : const Value.absent(),
        ),
      );
    }
    ref.invalidate(journalTemplatesProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Yeni şablon',
          style: theme.titleMedium?.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Kaydet'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Şablon adı',
                hintText: 'Örn. Okuma günlüğü',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('İkon (emoji)', style: theme.labelMedium),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _pickEmoji(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(_emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Alanlar', style: theme.titleSmall),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _fields.add(_FieldEdit(
                        label: '',
                        fieldType: 'text',
                        isRequired: false,
                      ));
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Alan ekle'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _fields.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final item = _fields.removeAt(oldIndex);
                  if (newIndex > oldIndex) newIndex--;
                  _fields.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final f = _fields[index];
                return _FieldTile(
                  key: ValueKey('${f.label}$index'),
                  index: index,
                  field: f,
                  fieldTypes: _fieldTypes,
                  onChanged: (updated) {
                    setState(() => _fields[index] = updated);
                  },
                  onRemove: () => setState(() => _fields.removeAt(index)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickEmoji(BuildContext context) {
    final emojis = ['📝', '🤿', '🎾', '📚', '🏃', '🎬', '✈️', '🏋️', '🧘', '💧', '🌿', '✍️'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: emojis.map((e) => GestureDetector(
            onTap: () {
              setState(() => _emoji = e);
              Navigator.pop(ctx);
            },
            child: Text(e, style: const TextStyle(fontSize: 32)),
          )).toList(),
        ),
      ),
    );
  }
}

class _FieldEdit {
  _FieldEdit({
    required this.label,
    required this.fieldType,
    this.options,
    this.unit,
    this.isRequired = false,
  });
  String label;
  String fieldType;
  String? options;
  String? unit;
  bool isRequired;
}

class _FieldTile extends StatefulWidget {
  const _FieldTile({
    super.key,
    required this.index,
    required this.field,
    required this.fieldTypes,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _FieldEdit field;
  final List<String> fieldTypes;
  final void Function(_FieldEdit) onChanged;
  final VoidCallback onRemove;

  @override
  State<_FieldTile> createState() => _FieldTileState();
}

class _FieldTileState extends State<_FieldTile> {
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
  }

  @override
  void didUpdateWidget(_FieldTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.field.label != _labelController.text) {
      _labelController.text = widget.field.label;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final field = widget.field;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: widget.index,
          child: Icon(Icons.drag_handle, color: AppColors.textMuted(AppColors.textPrimary)),
        ),
        title: TextField(
          controller: _labelController,
          decoration: const InputDecoration(
            labelText: 'Etiket',
            isDense: true,
            border: InputBorder.none,
          ),
          onChanged: (v) => widget.onChanged(_FieldEdit(
            label: v,
            fieldType: field.fieldType,
            options: field.options,
            unit: field.unit,
            isRequired: field.isRequired,
          )),
        ),
        subtitle: Row(
          children: [
            DropdownButton<String>(
              value: field.fieldType,
              isDense: true,
              items: widget.fieldTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) {
                if (v != null) widget.onChanged(_FieldEdit(
                  label: _labelController.text,
                  fieldType: v,
                  options: field.options,
                  unit: field.unit,
                  isRequired: field.isRequired,
                ));
              },
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 24,
              child: Checkbox(
                value: field.isRequired,
                onChanged: (v) => widget.onChanged(_FieldEdit(
                  label: _labelController.text,
                  fieldType: field.fieldType,
                  options: field.options,
                  unit: field.unit,
                  isRequired: v ?? false,
                )),
              ),
            ),
            Text('Zorunlu', style: theme.labelSmall),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: widget.onRemove,
        ),
      ),
    );
  }
}
