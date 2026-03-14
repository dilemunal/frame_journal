import 'dart:ui';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../entry/presentation/widgets/glass_card.dart';

class TemplateBuilderScreen extends ConsumerStatefulWidget {
  const TemplateBuilderScreen({super.key});

  @override
  ConsumerState<TemplateBuilderScreen> createState() =>
      _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends ConsumerState<TemplateBuilderScreen> {
  final _nameController = TextEditingController();
  String _emoji = '📝';
  final String _color = '#8FA5BA';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Yeni şablon',
            style: theme.titleMedium?.copyWith(color: Colors.white),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: _save,
                child: const Text('Kaydet'),
              ),
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
                style: const TextStyle(color: Colors.white),
                decoration: _glassInputDecoration(
                  labelText: 'Şablon adı',
                  hintText: 'Orn. Okuma gunlugu',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'İkon (emoji)',
                    style: theme.labelMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _pickEmoji(context),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      borderRadius: 999,
                      opacity: 0.12,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: Text(_emoji, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alanlar',
                    style: theme.titleSmall?.copyWith(color: Colors.white),
                  ),
                  OutlinedButton.icon(
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    ),
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
      ),
    );
  }

  InputDecoration _glassInputDecoration({
    required String labelText,
    String? hintText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
    );
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
      ),
    );
  }

  void _pickEmoji(BuildContext context) {
    final emojis = ['📝', '🤿', '🎾', '📚', '🏃', '🎬', '✈️', '🏋️', '🧘', '💧', '🌿', '✍️'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: emojis
                  .map(
                    (e) => GestureDetector(
                      onTap: () {
                        setState(() => _emoji = e);
                        Navigator.pop(ctx);
                      },
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: 999,
                        opacity: 0.12,
                        child: SizedBox(
                          width: 54,
                          height: 54,
                          child: Center(
                            child: Text(e, style: const TextStyle(fontSize: 30)),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
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
    return GlassCard(
      padding: EdgeInsets.zero,
      opacity: 0.10,
      borderRadius: 14,
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: widget.index,
          child: Icon(Icons.drag_handle, color: Colors.white.withValues(alpha: 0.6)),
        ),
        title: TextField(
          controller: _labelController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Etiket',
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
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
              dropdownColor: const Color(0xFF253040),
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white.withValues(alpha: 0.9),
              items: widget.fieldTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) {
                if (v != null) {
                  widget.onChanged(_FieldEdit(
                    label: _labelController.text,
                    fieldType: v,
                    options: field.options,
                    unit: field.unit,
                    isRequired: field.isRequired,
                  ));
                }
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
                activeColor: Colors.white,
                checkColor: const Color(0xFF2A2A2A),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
            ),
            Text(
              'Zorunlu',
              style: theme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline, color: Colors.white.withValues(alpha: 0.8)),
          onPressed: widget.onRemove,
        ),
      ),
    );
  }
}
