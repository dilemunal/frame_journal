import 'dart:convert';
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
  String _color = '#8FA5BA';
  final List<_FieldEdit> _fields = [];
  static const _colorPresets = <String>[
    '#8FA5BA',
    '#4DB6AC',
    '#F4A261',
    '#E76F51',
    '#7E57C2',
    '#EC407A',
    '#9CCC65',
    '#90CAF9',
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
      final encodedOptions = _encodeFieldOptions(f);
      await db.into(db.templateFields).insert(
        TemplateFieldsCompanion.insert(
          templateId: id,
          label: f.label.trim().isEmpty ? _defaultLabelForType(f.fieldType) : f.label.trim(),
          fieldType: f.fieldType,
          options: encodedOptions != null
              ? Value(encodedOptions)
              : const Value.absent(),
          isRequired: Value(f.isRequired),
          sortOrder: i,
          unit: f.unit.trim().isNotEmpty
              ? Value(f.unit.trim())
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
              const SizedBox(height: 14),
              Text(
                'Renk',
                style: theme.labelMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colorPresets.map((hex) {
                  final selected = hex == _color;
                  final c = _hexColor(hex);
                  return GestureDetector(
                    onTap: () => setState(() => _color = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c,
                        border: Border.all(
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
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
                    onPressed: _showAddFieldTypeSheet,
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
                    key: ValueKey('field_$index'),
                    index: index,
                    field: f,
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

  Future<void> _showAddFieldTypeSheet() async {
    final selectedType = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: FractionallySizedBox(
            heightFactor: 0.78,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alan tipi sec',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: GridView.builder(
                          itemCount: _fieldTypeCards.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.38,
                          ),
                          itemBuilder: (context, index) {
                            final spec = _fieldTypeCards[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => Navigator.of(ctx).pop(spec.type),
                              child: GlassCard(
                                borderRadius: 14,
                                opacity: 0.10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      spec.icon,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      spec.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      spec.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.68),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (selectedType == null || !mounted) return;
    setState(() {
      _fields.add(_FieldEdit.forType(selectedType));
    });
  }

  String? _encodeFieldOptions(_FieldEdit field) {
    if (field.fieldType == 'slider') {
      return jsonEncode({
        'min': field.sliderMin,
        'max': field.sliderMax,
      });
    }
    if (field.fieldType == 'select' || field.fieldType == 'tags') {
      return field.choices.isEmpty ? null : jsonEncode({'items': field.choices});
    }
    if (field.fieldType == 'number' && field.unit.trim().isNotEmpty) {
      return jsonEncode({'unit': field.unit.trim()});
    }
    return null;
  }

  String _defaultLabelForType(String type) {
    switch (type) {
      case 'number':
        return 'Sayi';
      case 'slider':
        return 'Skala';
      case 'text':
        return 'Kisa Metin';
      case 'long_text':
        return 'Uzun Metin';
      case 'select':
        return 'Tek Secim';
      case 'tags':
        return 'Coklu Secim';
      case 'location':
        return 'Konum';
      case 'photo':
        return 'Fotograf';
      case 'weather':
        return 'Hava Durumu';
      default:
        return 'Alan';
    }
  }

  Color _hexColor(String hex) {
    final raw = hex.replaceFirst('#', '');
    final value = int.tryParse(raw, radix: 16) ?? 0x8FA5BA;
    return Color(0xFF000000 | value);
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
    required this.unit,
    required this.sliderMin,
    required this.sliderMax,
    required this.choices,
    this.isRequired = false,
    this.expanded = false,
  });

  factory _FieldEdit.forType(String type) {
    return _FieldEdit(
      label: '',
      fieldType: type,
      unit: '',
      sliderMin: 0,
      sliderMax: 10,
      choices: const [],
    );
  }

  String label;
  String fieldType;
  String unit;
  double sliderMin;
  double sliderMax;
  List<String> choices;
  bool isRequired;
  bool expanded;

  _FieldEdit copyWith({
    String? label,
    String? fieldType,
    String? unit,
    double? sliderMin,
    double? sliderMax,
    List<String>? choices,
    bool? isRequired,
    bool? expanded,
  }) {
    return _FieldEdit(
      label: label ?? this.label,
      fieldType: fieldType ?? this.fieldType,
      unit: unit ?? this.unit,
      sliderMin: sliderMin ?? this.sliderMin,
      sliderMax: sliderMax ?? this.sliderMax,
      choices: choices ?? List<String>.from(this.choices),
      isRequired: isRequired ?? this.isRequired,
      expanded: expanded ?? this.expanded,
    );
  }
}

class _FieldTile extends StatefulWidget {
  const _FieldTile({
    super.key,
    required this.index,
    required this.field,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _FieldEdit field;
  final void Function(_FieldEdit) onChanged;
  final VoidCallback onRemove;

  @override
  State<_FieldTile> createState() => _FieldTileState();
}

class _FieldTileState extends State<_FieldTile> {
  late TextEditingController _labelController;
  late TextEditingController _unitController;
  late TextEditingController _sliderMinController;
  late TextEditingController _sliderMaxController;
  final _choiceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
    _unitController = TextEditingController(text: widget.field.unit);
    _sliderMinController =
        TextEditingController(text: widget.field.sliderMin.toStringAsFixed(0));
    _sliderMaxController =
        TextEditingController(text: widget.field.sliderMax.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(_FieldTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.field.label != _labelController.text) {
      _labelController.text = widget.field.label;
    }
    if (widget.field.unit != _unitController.text) {
      _unitController.text = widget.field.unit;
    }
    final minText = widget.field.sliderMin.toStringAsFixed(0);
    final maxText = widget.field.sliderMax.toStringAsFixed(0);
    if (_sliderMinController.text != minText) {
      _sliderMinController.text = minText;
    }
    if (_sliderMaxController.text != maxText) {
      _sliderMaxController.text = maxText;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _unitController.dispose();
    _sliderMinController.dispose();
    _sliderMaxController.dispose();
    _choiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final spec = _fieldSpec(field.fieldType);

    return Dismissible(
      key: ValueKey('field_${widget.index}_${field.fieldType}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GlassCard(
        padding: EdgeInsets.zero,
        opacity: 0.10,
        borderRadius: 14,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => widget.onChanged(field.copyWith(expanded: !field.expanded)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                child: Row(
                  children: [
                    Text(spec.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        field.label.trim().isEmpty ? spec.title : field.label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: Icon(
                        Icons.drag_handle_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      field.expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
            ),
            if (field.expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _glassTextField(
                      controller: _labelController,
                      label: 'Etiket',
                      onChanged: (v) => widget.onChanged(field.copyWith(label: v)),
                    ),
                    const SizedBox(height: 10),
                    if (field.fieldType == 'number') _numberSettings(field),
                    if (field.fieldType == 'slider') _sliderSettings(field),
                    if (field.fieldType == 'select' || field.fieldType == 'tags')
                      _choiceSettings(field),
                    Row(
                      children: [
                        Checkbox(
                          value: field.isRequired,
                          onChanged: (v) => widget.onChanged(
                            field.copyWith(isRequired: v ?? false),
                          ),
                          activeColor: Colors.white,
                          checkColor: const Color(0xFF2A2A2A),
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        Text(
                          'Bu alan zorunlu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: widget.onRemove,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _numberSettings(_FieldEdit field) {
    return _glassTextField(
      controller: _unitController,
      label: 'Birim (m, km, dk, °C, bpm, kg...)',
      onChanged: (v) => widget.onChanged(field.copyWith(unit: v)),
    );
  }

  Widget _sliderSettings(_FieldEdit field) {
    return Row(
      children: [
        Expanded(
          child: _glassTextField(
            controller: _sliderMinController,
            label: 'Min',
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final parsed = double.tryParse(v.replaceAll(',', '.'));
              if (parsed != null) {
                widget.onChanged(field.copyWith(sliderMin: parsed));
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _glassTextField(
            controller: _sliderMaxController,
            label: 'Max',
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final parsed = double.tryParse(v.replaceAll(',', '.'));
              if (parsed != null) {
                widget.onChanged(field.copyWith(sliderMax: parsed));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _choiceSettings(_FieldEdit field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _glassTextField(
          controller: _choiceController,
          label: 'Secenek ekle ve Enter',
          onSubmitted: (v) {
            final text = v.trim();
            if (text.isEmpty) return;
            if (!field.choices.contains(text)) {
              widget.onChanged(field.copyWith(choices: [...field.choices, text]));
            }
            _choiceController.clear();
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: field.choices
              .map(
                (c) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c, style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          final next = [...field.choices]..remove(c);
                          widget.onChanged(field.copyWith(choices: next));
                        },
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _glassTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.52)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.09),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
        ),
      ),
    );
  }
}

class _FieldTypeCardSpec {
  const _FieldTypeCardSpec({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String type;
  final String title;
  final String description;
  final String icon;
}

const List<_FieldTypeCardSpec> _fieldTypeCards = [
  _FieldTypeCardSpec(
    type: 'number',
    title: 'Sayi',
    description: 'Derinlik, sure, mesafe',
    icon: '123',
  ),
  _FieldTypeCardSpec(
    type: 'slider',
    title: 'Skala',
    description: 'Enerji, his, puan',
    icon: '—●—',
  ),
  _FieldTypeCardSpec(
    type: 'text',
    title: 'Kisa Metin',
    description: 'Tek satir bilgi',
    icon: 'Aa',
  ),
  _FieldTypeCardSpec(
    type: 'long_text',
    title: 'Uzun Metin',
    description: 'Notlar, dusunceler',
    icon: '¶',
  ),
  _FieldTypeCardSpec(
    type: 'select',
    title: 'Tek Secim',
    description: 'Acik/Kapali, Mac',
    icon: '◉ ○ ○',
  ),
  _FieldTypeCardSpec(
    type: 'tags',
    title: 'Coklu Secim',
    description: 'Ekipmanlar, etiketler',
    icon: '◉ ◉ ○',
  ),
  _FieldTypeCardSpec(
    type: 'location',
    title: 'Konum',
    description: 'Nerede yaptin',
    icon: '📍',
  ),
  _FieldTypeCardSpec(
    type: 'photo',
    title: 'Fotograf',
    description: 'Gorsel kayit',
    icon: '📸',
  ),
  _FieldTypeCardSpec(
    type: 'weather',
    title: 'Hava Durumu',
    description: 'Otomatik dolabilir',
    icon: '🌤️',
  ),
];

_FieldTypeCardSpec _fieldSpec(String type) {
  return _fieldTypeCards.firstWhere(
    (e) => e.type == type,
    orElse: () => const _FieldTypeCardSpec(
      type: 'text',
      title: 'Alan',
      description: '',
      icon: '📝',
    ),
  );
}
