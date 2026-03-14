import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/services/location_service.dart';
import 'glass_card.dart';

class TemplateFieldInput extends ConsumerStatefulWidget {
  const TemplateFieldInput({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.showError = false,
  });

  final TemplateField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool showError;

  @override
  ConsumerState<TemplateFieldInput> createState() => _TemplateFieldInputState();
}

class _TemplateFieldInputState extends ConsumerState<TemplateFieldInput> {
  late final TextEditingController _textController;
  late final TextEditingController _manualLocationController;
  late final TextEditingController _manualWeatherController;
  Timer? _numberTimer;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _valueAsText(widget.value));
    _manualLocationController = TextEditingController(text: _manualLocationText(widget.value));
    _manualWeatherController = TextEditingController(text: _manualWeatherText(widget.value));
  }

  @override
  void didUpdateWidget(covariant TemplateFieldInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _textController.text = _valueAsText(widget.value);
      _manualLocationController.text = _manualLocationText(widget.value);
      _manualWeatherController.text = _manualWeatherText(widget.value);
    }
  }

  @override
  void dispose() {
    _numberTimer?.cancel();
    _textController.dispose();
    _manualLocationController.dispose();
    _manualWeatherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      color: widget.showError
          ? const Color(0xFFFF8A80)
          : Colors.white.withValues(alpha: 0.72),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    return GlassCard(
      opacity: widget.showError ? 0.16 : 0.1,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.field.label}${widget.field.isRequired ? ' *' : ''}',
            style: labelStyle,
          ),
          const SizedBox(height: 8),
          _buildByType(context),
        ],
      ),
    );
  }

  Widget _buildByType(BuildContext context) {
    switch (widget.field.fieldType) {
      case 'long_text':
        return _textInput(minLines: 3, maxLines: null);
      case 'text':
        return _textInput(minLines: 1, maxLines: 1);
      case 'number':
        return _numberInput();
      case 'slider':
        return _sliderInput();
      case 'select':
        return _choiceInput(multi: false);
      case 'tags':
        return _choiceInput(multi: true);
      case 'location':
        return _locationInput();
      case 'weather':
        return _weatherInput();
      case 'photo':
        return _photoInput();
      default:
        return _textInput(minLines: 1, maxLines: 1);
    }
  }

  Widget _textInput({required int minLines, required int? maxLines}) {
    return TextField(
      controller: _textController,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Yaz...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
      ),
    );
  }

  Widget _numberInput() {
    final value = (widget.value is num) ? (widget.value as num).toDouble() : 0.0;
    final unit = _numberUnit(widget.field);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _numberButton(
            icon: Icons.remove,
            onTap: () => widget.onChanged(value - 1),
            onLongStart: () => _startNumberRepeat(value, -1),
            onLongEnd: _stopNumberRepeat,
          ),
          Expanded(
            child: InkWell(
              onTap: () => _showNumberDialog(value),
              child: Column(
                children: [
                  Text(
                    value.toStringAsFixed(value % 1 == 0 ? 0 : 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    Text(
                      unit,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
          _numberButton(
            icon: Icons.add,
            onTap: () => widget.onChanged(value + 1),
            onLongStart: () => _startNumberRepeat(value, 1),
            onLongEnd: _stopNumberRepeat,
          ),
        ],
      ),
    );
  }

  Widget _numberButton({
    required IconData icon,
    required VoidCallback onTap,
    required VoidCallback onLongStart,
    required VoidCallback onLongEnd,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (_) => onLongStart(),
      onLongPressEnd: (_) => onLongEnd(),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  void _startNumberRepeat(double base, int delta) {
    _numberTimer?.cancel();
    var current = base;
    _numberTimer = Timer.periodic(const Duration(milliseconds: 95), (_) {
      current += delta;
      widget.onChanged(current);
    });
  }

  void _stopNumberRepeat() {
    _numberTimer?.cancel();
    _numberTimer = null;
  }

  Future<void> _showNumberDialog(double value) async {
    final c = TextEditingController(text: value.toStringAsFixed(value % 1 == 0 ? 0 : 1));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deger gir'),
        content: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Iptal')),
          FilledButton(
            onPressed: () => Navigator.pop(
              ctx,
              double.tryParse(c.text.replaceAll(',', '.')),
            ),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
    if (result != null) {
      widget.onChanged(result);
    }
  }

  Widget _sliderInput() {
    final range = _sliderRange(widget.field.options);
    final raw = (widget.value is num) ? (widget.value as num).toDouble() : range.$1;
    final value = raw.clamp(range.$1, range.$2);
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF9CD3FF),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.22),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: range.$1,
            max: range.$2,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }

  Widget _choiceInput({required bool multi}) {
    final options = _optionsFromField(widget.field.options);
    final selected = multi
        ? _valueAsStringList(widget.value).toSet()
        : <String>{if (_valueAsText(widget.value).isNotEmpty) _valueAsText(widget.value)};
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((item) {
        final isSelected = selected.contains(item);
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            if (multi) {
              final next = {...selected};
              if (isSelected) {
                next.remove(item);
              } else {
                next.add(item);
              }
              widget.onChanged(next.toList());
            } else {
              widget.onChanged(isSelected ? '' : item);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1F2B3A) : Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _locationInput() {
    final selected = _decodeMap(widget.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            foregroundColor: Colors.white,
          ),
          onPressed: _useCurrentLocation,
          child: const Text('📍 Konumumu kullan'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _manualLocationController,
          style: const TextStyle(color: Colors.white),
          onChanged: (v) => widget.onChanged(jsonEncode({'name': v.trim()})),
          decoration: InputDecoration(
            hintText: 'veya yaz...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: InputBorder.none,
          ),
        ),
        if ((selected['name'] ?? '').toString().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '📍 ${selected['name']}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => widget.onChanged(''),
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _useCurrentLocation() async {
    final loc = await LocationService().getCurrentLocation();
    if (loc == null || !mounted) return;
    widget.onChanged(jsonEncode({
      'lat': loc.lat,
      'lng': loc.lng,
      'name': loc.placeName,
    }));
  }

  Widget _weatherInput() {
    final atm = ref.watch(atmosphereProvider).valueOrNull;
    final canAuto = atm?.weather != null;
    if (canAuto) {
      final text =
          '${atm!.weather!.emoji} ${atm.weather!.temp}°C ${atm.weather!.description}';
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          widget.onChanged(jsonEncode({
            'temp': atm.weather!.temp,
            'condition': atm.weather!.description,
            'emoji': atm.weather!.emoji,
          }));
        },
        child: Text('$text — Otomatik kullan'),
      );
    }
    return TextField(
      controller: _manualWeatherController,
      style: const TextStyle(color: Colors.white),
      onChanged: (v) => widget.onChanged(jsonEncode({'condition': v.trim()})),
      decoration: InputDecoration(
        hintText: 'Hava durumunu yaz...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: InputBorder.none,
      ),
    );
  }

  Widget _photoInput() {
    final photos = _valueAsStringList(widget.value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _pickPhotos,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('+ Fotograf ekle'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: 10),
          GridView.builder(
            itemCount: photos.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final path = photos[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(path), fit: BoxFit.cover),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: GestureDetector(
                        onTap: () {
                          final next = [...photos]..removeAt(index);
                          widget.onChanged(next);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Future<void> _pickPhotos() async {
    try {
      final picker = ImagePicker();
      final xs = await picker.pickMultiImage();
      if (xs.isEmpty) return;
      final current = _valueAsStringList(widget.value);
      widget.onChanged([...current, ...xs.map((e) => e.path)]);
    } catch (_) {}
  }
}

String _valueAsText(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is num) return value.toString();
  return '';
}

List<String> _valueAsStringList(dynamic value) {
  if (value is List) return value.map((e) => '$e').toList();
  if (value is String && value.startsWith('[')) {
    try {
      final raw = jsonDecode(value);
      if (raw is List) return raw.map((e) => '$e').toList();
    } catch (_) {}
  }
  return [];
}

Map<String, dynamic> _decodeMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is String && raw.trim().startsWith('{')) {
    try {
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
  }
  return {};
}

String _manualLocationText(dynamic value) => (_decodeMap(value)['name'] ?? '').toString();

String _manualWeatherText(dynamic value) {
  final map = _decodeMap(value);
  return (map['condition'] ?? '').toString();
}

List<String> _optionsFromField(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic> && decoded['items'] is List) {
      return (decoded['items'] as List).map((e) => '$e').toList();
    }
  } catch (_) {}
  return raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

(double, double) _sliderRange(String? raw) {
  if (raw == null || raw.isEmpty) return (0, 10);
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final min = (decoded['min'] as num?)?.toDouble();
      final max = (decoded['max'] as num?)?.toDouble();
      if (min != null && max != null && max > min) {
        return (min, max);
      }
    }
  } catch (_) {}
  return (0, 10);
}

String _numberUnit(TemplateField field) {
  if (field.unit != null && field.unit!.trim().isNotEmpty) return field.unit!.trim();
  if (field.options != null) {
    try {
      final decoded = jsonDecode(field.options!);
      if (decoded is Map<String, dynamic> && decoded['unit'] != null) {
        return '${decoded['unit']}';
      }
    } catch (_) {}
  }
  return '';
}
