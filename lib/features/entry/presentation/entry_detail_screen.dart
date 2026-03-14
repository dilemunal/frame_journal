import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Tek bir girişin tam içeriğini gösterir. Rota: /entry/:id
class EntryDetailScreen extends ConsumerWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final async = ref.watch(entryDetailProvider(entryId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: async.when(
        data: (pair) {
          if (pair == null) {
            return Center(
              child: Text(
                'Giriş bulunamadı.',
                style: theme.bodyMedium?.copyWith(
                  color: AppColors.textMuted(AppColors.textPrimary),
                ),
              ),
            );
          }
          final (entry, template) = pair;
          return _EntryDetailBody(entry: entry, template: template);
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Yüklenemedi.',
            style: theme.bodyMedium?.copyWith(
              color: AppColors.textMuted(AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryDetailBody extends StatelessWidget {
  const _EntryDetailBody({required this.entry, this.template});

  final AppEntry entry;
  final JournalTemplate? template;

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
    final body = entry.freeText ?? entry.title ?? '—';

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: theme.labelMedium?.copyWith(
              color: AppColors.textMuted(AppColors.textPrimary),
            ),
          ),
          if ((entry.mood?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                entry.mood ?? '',
                style: theme.labelMedium?.copyWith(
                  color: AppColors.accent,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color != null
                  ? color.withValues(alpha: 0.1)
                  : AppColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: color != null
                  ? Border(left: BorderSide(color: color, width: 4))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              body,
              style: theme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
