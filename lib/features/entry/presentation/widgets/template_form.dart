import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import 'glass_card.dart';
import 'template_field_input.dart';

class TemplateForm extends ConsumerStatefulWidget {
  const TemplateForm({
    super.key,
    required this.templateId,
    required this.onValuesChanged,
    this.onRequiredStateChanged,
    this.onNotesChanged,
    this.validateSignal = 0,
  });

  final int templateId;
  final ValueChanged<Map<int, dynamic>> onValuesChanged;
  final ValueChanged<bool>? onRequiredStateChanged;
  final ValueChanged<String>? onNotesChanged;
  final int validateSignal;

  @override
  ConsumerState<TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends ConsumerState<TemplateForm> {
  final Map<int, dynamic> _values = {};
  bool _showValidation = false;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TemplateForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.validateSignal != oldWidget.validateSignal) {
      setState(() => _showValidation = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncFields = ref.watch(templateFieldsProvider(widget.templateId));
    return asyncFields.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (fields) {
        final filledCount = fields.where((f) => _isFilled(_values[f.id], f.fieldType)).length;
        final required = fields.where((f) => f.isRequired).toList();
        final requiredDone = required.every((f) => _isFilled(_values[f.id], f.fieldType));
        widget.onRequiredStateChanged?.call(requiredDone);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              opacity: 0.1,
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$filledCount / ${fields.length} alan dolduruldu',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      if (requiredDone)
                        const Icon(Icons.check_circle, color: Colors.lightGreenAccent),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: fields.isEmpty ? 0 : filledCount / fields.length,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ...fields.map((field) {
              final value = _values[field.id];
              final showError = _showValidation &&
                  field.isRequired &&
                  !_isFilled(value, field.fieldType);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TemplateFieldInput(
                  field: field,
                  value: value,
                  showError: showError,
                  onChanged: (next) {
                    setState(() {
                      _values[field.id] = next;
                    });
                    widget.onValuesChanged(Map<int, dynamic>.from(_values));
                  },
                ),
              );
            }),
            GlassCard(
              opacity: 0.1,
              borderRadius: 16,
              child: TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: null,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => widget.onNotesChanged?.call(v),
                decoration: InputDecoration(
                  hintText: 'Ek notlar...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isFilled(dynamic value, String type) {
    if (value == null) return false;
    if (type == 'photo') {
      if (value is List) return value.isNotEmpty;
      return false;
    }
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is num) return true;
    if (value is Map) return value.isNotEmpty;
    return false;
  }
}
