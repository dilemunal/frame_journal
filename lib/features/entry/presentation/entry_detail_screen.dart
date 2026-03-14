import 'dart:convert';
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

class _Body extends StatelessWidget {
  const _Body({required this.entry, required this.template});

  final AppEntry entry;
  final JournalTemplate? template;

  @override
  Widget build(BuildContext context) {
    final title = template?.name ?? 'Giriş';
    final icon = template?.icon ?? '📝';
    final body = entry.freeText ?? entry.title ?? '—';
    final date = _date(entry.createdAt);
    final loc = _decode(entry.locationJson);
    final weather = _decode(entry.weatherJson);

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
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            title: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                        '${weather['emoji'] ?? '🌤️'} ${weather['temp']}°C ${weather['condition'] ?? ''}',
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
              ],
            ),
          ),
        ),
      ],
    );
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
}

