import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import 'widgets/glass_card.dart';

class EntryDetailScreen extends ConsumerWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(entryDetailProvider(entryId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (e, s) => Center(
            child: Text(
              'Yüklenemedi.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          data: (pair) {
            if (pair == null) {
              return Center(
                child: Text(
                  'Giriş bulunamadı.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              );
            }
            return _Body(entry: pair.$1, template: pair.$2);
          },
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.entry, required this.template});

  final AppEntry entry;
  final JournalTemplate? template;

  Future<void> _deleteEntry(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Girişi sil'),
        content: const Text('Bu girişi silmek istediğine emin misin? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sil', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final db = ref.read(appDatabaseProvider);
    await (db.delete(db.appEntries)..where((e) => e.id.equals(entry.id))).go();
    ref.invalidate(entryDetailProvider(entry.id));
    ref.invalidate(recentEntriesProvider);
    ref.invalidate(memoryEntriesProvider);
    ref.invalidate(filmRollFramesProvider);
    ref.invalidate(filteredMemoryEntriesProvider);
    ref.invalidate(usedTemplatesProvider);
    ref.invalidate(templateUsageCountProvider);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = template?.name ?? 'Giriş';
    final icon = template?.icon ?? '📝';
    final body = entry.freeText ?? entry.title ?? '—';
    final date = _date(entry.createdAt);
    final loc = _decode(entry.locationJson);
    final weather = _decode(entry.weatherJson);
    final valuesRoot = _decode(entry.valuesJson);
    final templateValues = _decodeAnyMap(valuesRoot['templateValues']);
    final templatePhotos = _decodeAnyList(valuesRoot['templatePhotos']);
    final fieldsAsync = template == null
        ? const AsyncValue<List<TemplateField>>.data(<TemplateField>[])
        : ref.watch(templateFieldsProvider(template!.id));
    final isLocked = entry.unlockAt != null &&
        DateTime.now().isBefore(entry.unlockAt!);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          floating: true,
          pinned: false,
          expandedHeight: 140,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.pushNamed(
                'entryNew',
                queryParameters: {'editEntryId': '${entry.id}'},
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _deleteEntry(context, ref),
            ),
          ],
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isLocked)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_clock_rounded,
                      size: 72,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Zaman kapsülü',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bu giriş ${_date(entry.unlockAt!)} tarihinde açılacak.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Geçmişe mektup — o gün gelene kadar bekleyeceksin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _metaPill('🗓️ $date'),
                    if ((entry.mood ?? '').isNotEmpty) _metaPill('Ruh ${entry.mood}'),
                    if ((loc['name'] ?? '').toString().isNotEmpty)
                      _metaPill('📍 ${loc['name']}'),
                    if ((weather['temp'] ?? '').toString().isNotEmpty)
                      _metaPill(
                        '${weather['emoji'] ?? '🌤️'} ${weather['temp']}°C',
                      ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 320.ms)
                    .slideY(begin: 0.08, end: 0, duration: 320.ms),
                const SizedBox(height: 14),
                GlassCard(
                  opacity: 0.1,
                  borderRadius: 18,
                  child: Text(
                    body,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.8,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 320.ms)
                    .slideY(begin: 0.08, end: 0, delay: 150.ms, duration: 320.ms),
                fieldsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                  data: (fields) {
                    final visible = fields
                        .where((f) => _hasFieldValue(templateValues['${f.id}']))
                        .toList();
                    if (visible.isEmpty && templatePhotos.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...visible.map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _fieldView(
                                f,
                                templateValues['${f.id}'],
                              ),
                            ),
                          ),
                          if (templatePhotos.isNotEmpty)
                            GlassCard(
                              borderRadius: 16,
                              opacity: 0.1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fotoğraflar',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.72),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GridView.builder(
                                    itemCount: templatePhotos.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemBuilder: (context, index) {
                                      final path = templatePhotos[index];
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: _safeFileImage(path),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldView(TemplateField field, dynamic value) {
    final label = field.label;
    switch (field.fieldType) {
      case 'number':
        return GlassCard(
          borderRadius: 16,
          opacity: 0.1,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _unitFor(field),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
              ),
            ],
          ),
        );
      case 'slider':
        final range = _sliderRange(field.options);
        final number = value is num
            ? value.toDouble()
            : double.tryParse('$value'.replaceAll(',', '.')) ?? range.$1;
        final t = ((number - range.$1) / (range.$2 - range.$1)).clamp(0.0, 1.0);
        return GlassCard(
          borderRadius: 16,
          opacity: 0.1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: t,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9CD3FF)),
              ),
              const SizedBox(height: 6),
              Text('$number', style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      case 'select':
      case 'tags':
        final chips = value is List ? value : [value];
        return GlassCard(
          borderRadius: 16,
          opacity: 0.1,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('$c', style: const TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
          ),
        );
      case 'location':
        final map = _decodeAnyMap(value);
        return GlassCard(
          borderRadius: 16,
          opacity: 0.1,
          child: Text(
            '📍 ${map['name'] ?? value}',
            style: const TextStyle(color: Colors.white),
          ),
        );
      case 'weather':
        final map = _decodeAnyMap(value);
        return GlassCard(
          borderRadius: 16,
          opacity: 0.1,
          child: Text(
            '${map['emoji'] ?? '🌤️'} ${map['temp'] ?? ''}°C ${map['condition'] ?? ''}',
            style: const TextStyle(color: Colors.white),
          ),
        );
      case 'photo':
        final photos = _decodeAnyList(value);
        if (photos.isEmpty) return const SizedBox.shrink();
        return GlassCard(
          borderRadius: 16,
          opacity: 0.1,
          child: GridView.builder(
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
                child: _safeFileImage(path),
              );
            },
          ),
        );
      default:
        return GlassCard(
          borderRadius: 16,
          opacity: 0.1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              Text('$value', style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
    }
  }

  Widget _metaPill(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  static String _date(DateTime d) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static Map<String, dynamic> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw);
      return map is Map<String, dynamic> ? map : {};
    } catch (_) {
      return {};
    }
  }

  static bool _hasFieldValue(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is num) return true;
    if (value is Map) return value.isNotEmpty;
    return false;
  }

  static Map<String, dynamic> _decodeAnyMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.startsWith('{')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  static List<String> _decodeAnyList(dynamic raw) {
    if (raw is List) return raw.map((e) => '$e').toList();
    if (raw is String && raw.startsWith('[')) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded.map((e) => '$e').toList();
      } catch (_) {}
    }
    return const [];
  }

  static (double, double) _sliderRange(String? raw) {
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

  static Widget _safeFileImage(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.trim().isEmpty) return _brokenImagePlaceholder();
    final file = File(path);
    if (!file.existsSync()) return _brokenImagePlaceholder();
    return Image.file(file, fit: fit);
  }

  static Widget _brokenImagePlaceholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.08),
      child: Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white.withValues(alpha: 0.4), size: 40),
      ),
    );
  }

  static String _unitFor(TemplateField field) {
    if (field.unit != null && field.unit!.isNotEmpty) return field.unit!;
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
}

