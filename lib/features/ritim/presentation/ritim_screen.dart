import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/rhythm_provider.dart';

/// Ritim ekranı — günlük ritim blokları (Sabah / Öğlen / Akşam) ve tamamlanma.
class RitimScreen extends ConsumerWidget {
  const RitimScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final asyncCompleted = ref.watch(rhythmCompletionsProvider);
    final notifier = ref.read(rhythmCompletionsProvider.notifier);
    final completed = asyncCompleted.valueOrNull ?? <String>{};

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
                  'Ritim',
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
                  'Günlük ritmin — bugün hangi blokları tamamladın?',
                  style: theme.bodyMedium?.copyWith(
                    color: AppColors.textMuted(AppColors.textPrimary),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            asyncCompleted.when(
              data: (_) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final key = kRhythmSlotKeys[index];
                    final label = kRhythmSlotLabels[key] ?? key;
                    final isDone = completed.contains(key);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _RhythmBlockCard(
                        label: label,
                        slotKey: key,
                        isCompleted: isDone,
                        onTap: () => notifier.toggle(key),
                      ),
                    );
                  },
                  childCount: kRhythmSlotKeys.length,
                ),
              ),
              loading: () => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
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
                    'Ritim yüklenemedi.',
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

class _RhythmBlockCard extends StatelessWidget {
  const _RhythmBlockCard({
    required this.label,
    required this.slotKey,
    required this.isCompleted,
    required this.onTap,
  });

  final String label;
  final String slotKey;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : AppColors.background.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : _iconForSlot(slotKey),
                  size: 26,
                  color: isCompleted
                      ? AppColors.accent
                      : AppColors.textMuted(AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted(AppColors.textPrimary),
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: isCompleted,
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForSlot(String slotKey) {
  switch (slotKey) {
    case 'morning':
      return Icons.wb_sunny_outlined;
    case 'noon':
      return Icons.light_mode_outlined;
    case 'evening':
      return Icons.nights_stay_outlined;
    default:
      return Icons.schedule_outlined;
  }
}
