import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Hafıza kartı — geçmiş girişleri kart görünümünde listeler.
class HafizaScreen extends ConsumerWidget {
  const HafizaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final asyncEntries = ref.watch(memoryEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Hafıza',
                  style: theme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Geçmiş girişlerin — kartlarda göz at.',
                  style: theme.bodyMedium?.copyWith(
                    color: AppColors.textMuted(AppColors.textPrimary),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            asyncEntries.when(
              data: (list) {
                if (list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Henüz giriş yok. Ana sayfadan "Bugünü kaydet" ile başla.',
                        style: theme.bodyMedium?.copyWith(
                          color: AppColors.textMuted(AppColors.textPrimary),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final (entry, template) = list[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _MemoryCard(
                          entry: entry,
                          template: template,
                          onTap: () =>
                              context.push('/entry/${entry.id}'),
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              error: (err, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Girişler yüklenemedi.',
                    style: theme.bodyMedium?.copyWith(
                      color: AppColors.textMuted(AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.entry,
    this.template,
    this.onTap,
  });

  final AppEntry entry;
  final JournalTemplate? template;
  final VoidCallback? onTap;

  static String _preview(String? freeText, String? title) {
    final raw = freeText ?? title ?? '';
    if (raw.isEmpty) return '—';
    return raw.length > 80 ? '${raw.substring(0, 80)}...' : raw;
  }

  static String _dateStr(DateTime d) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static Color? _parseColor(String hex) {
    if (hex.length != 7 || !hex.startsWith('#')) return null;
    final r = int.tryParse(hex.substring(1, 3), radix: 16);
    final g = int.tryParse(hex.substring(3, 5), radix: 16);
    final b = int.tryParse(hex.substring(5, 7), radix: 16);
    if (r == null || g == null || b == null) return null;
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final title = template?.name ?? 'Giriş';
    final emoji = template?.icon ?? '📝';
    final color = template != null ? _parseColor(template!.color) : null;
    final date = _dateStr(entry.createdAt);
    final preview = _preview(entry.freeText, entry.title);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color != null
                ? color.withValues(alpha: 0.12)
                : AppColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: color != null
                ? Border(left: BorderSide(color: color, width: 4))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                date,
                style: theme.labelSmall?.copyWith(
                  color: AppColors.textMuted(AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            preview,
            style: theme.bodyMedium?.copyWith(
              color: AppColors.textMuted(AppColors.textPrimary),
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (entry.mood != null && entry.mood!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Ruh hali: ${entry.mood}',
              style: theme.labelSmall?.copyWith(
                color: AppColors.accent,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
          ),
        ),
      ),
    );
  }
}
