import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';

class HafizaScreen extends ConsumerWidget {
  const HafizaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(memoryEntriesProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Hafıza',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                  child: Text(
                    'Geçmiş girişlerin, anılarını taşıyan kartlar.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              async.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
                error: (e, s) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Yüklenemedi.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Henüz giriş yok.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final (entry, template) = list[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _Card(
                          entry: entry,
                          template: template,
                          onTap: () => context.push('/entry/${entry.id}'),
                        )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 70 * index),
                              duration: 280.ms,
                            )
                            .slideY(
                              begin: 0.08,
                              end: 0,
                              delay: Duration(milliseconds: 70 * index),
                              duration: 280.ms,
                            ),
                      );
                    },
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.entry,
    required this.template,
    required this.onTap,
  });

  final AppEntry entry;
  final JournalTemplate? template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = _parseHexColor(template?.color ?? '');
    final preview = (entry.freeText ?? entry.title ?? '').trim();
    final text = preview.isEmpty
        ? '—'
        : (preview.length > 160 ? '${preview.substring(0, 160)}...' : preview);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tint != null
                  ? tint.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: tint != null
                    ? BorderSide(color: tint, width: 3)
                    : BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template?.name ?? 'Giriş',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.60),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _date(entry.createdAt),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.40)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color? _parseHexColor(String hex) {
    if (hex.length != 7 || !hex.startsWith('#')) return null;
    final r = int.tryParse(hex.substring(1, 3), radix: 16);
    final g = int.tryParse(hex.substring(3, 5), radix: 16);
    final b = int.tryParse(hex.substring(5, 7), radix: 16);
    if (r == null || g == null || b == null) return null;
    return Color.fromARGB(255, r, g, b);
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
}

