import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _animDuration = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final firstName = _firstNameFromEmail(auth.email);
    final now = DateTime.now();
    final hour = now.hour;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final anCardHeight = constraints.maxHeight * 0.35;
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(firstName: firstName),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  _AnCard(
                    height: anCardHeight,
                    hour: hour,
                    date: now,
                    showWeather: false,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                  _QuickEntryButton(
                    onTap: () => context.pushNamed('entryNew'),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.035),
                  const _TemplateCardsSection(),
                  SizedBox(height: constraints.maxHeight * 0.025),
                  const _SonGirislerSection(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _firstNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return '';
    final part = email.split('@').first;
    if (part.isEmpty) return '';
    return part.length > 1
        ? '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}'
        : part.toUpperCase();
  }

}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final greeting = firstName.isEmpty ? 'Merhaba.' : 'Merhaba, $firstName';
    final initials = firstName.isEmpty
        ? '?'
        : firstName.length >= 2
        ? firstName.substring(0, 2).toUpperCase()
        : firstName.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            greeting,
            style: theme.bodyMedium?.copyWith(
              color: AppColors.textMuted(AppColors.textPrimary),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surface,
            child: Text(
              initials,
              style: theme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTr(DateTime d) {
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
  const weekdays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];
  final wd = d.weekday - 1;
  return '${d.day} ${months[d.month - 1]}, ${weekdays[wd]}';
}

class _AnCard extends StatelessWidget {
  const _AnCard({
    required this.height,
    required this.hour,
    required this.date,
    required this.showWeather,
  });

  final double height;
  final int hour;
  final DateTime date;
  final bool showWeather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final tint = AppColors.anCardTintForHour(hour);
    final greeting = greetingForHour(hour);
    final dateStr = _formatDateTr(date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: _HomeScreenState._animDuration,
        curve: Curves.easeInOut,
        height: height,
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                greeting,
                style: theme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dateStr,
                style: theme.bodySmall?.copyWith(
                  color: AppColors.textMuted(AppColors.textPrimary),
                  letterSpacing: 0.5,
                  height: 1.4,
                ),
              ),
              if (showWeather) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      size: 18,
                      color: AppColors.textMuted(AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '— °C',
                      style: theme.bodySmall?.copyWith(
                        color: AppColors.textMuted(AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickEntryButton extends StatelessWidget {
  const _QuickEntryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Bugünü kaydet →',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateCardsSection extends ConsumerWidget {
  const _TemplateCardsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final templatesAsync = ref.watch(journalTemplatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Şablonlar',
            style: theme.labelMedium?.copyWith(
              color: AppColors.textMuted(AppColors.textPrimary),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 88,
          child: templatesAsync.when(
            data: (templates) {
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: templates.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  if (i == templates.length) {
                    return _TemplateChip(
                      emoji: '+',
                      label: 'Yeni şablon',
                      isNew: true,
                      onTap: () => context.pushNamed('templateBuilder'),
                    );
                  }
                  final t = templates[i];
                  return _TemplateChip(
                    emoji: t.icon,
                    label: t.name,
                    isNew: false,
                    onTap: () => context.pushNamed(
                      'entryNew',
                      queryParameters: {'templateId': '${t.id}'},
                    ),
                  );
                },
              );
            },
            loading: () => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) => _TemplateChip(
                emoji: i == 3 ? '+' : '📝',
                label: i == 3 ? 'Yeni şablon' : '...',
                isNew: i == 3,
              ),
            ),
            error: (_, __) => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _TemplateChip(
                  emoji: '+',
                  label: 'Yeni şablon',
                  isNew: true,
                  onTap: () => context.pushNamed('templateBuilder'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.emoji,
    required this.label,
    this.isNew = false,
    this.onTap,
  });

  final String emoji;
  final String label;
  final bool isNew;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.labelSmall?.copyWith(
            color: isNew
                ? AppColors.accent
                : AppColors.textMuted(AppColors.textPrimary),
            fontWeight: isNew ? FontWeight.w600 : FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
    return SizedBox(
      width: 100,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SonGirislerSection extends ConsumerWidget {
  const _SonGirislerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context).textTheme;
    final recentAsync = ref.watch(recentEntriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Son girişler',
            style: theme.labelMedium?.copyWith(
              color: AppColors.textMuted(AppColors.textPrimary),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        recentAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Henüz giriş yok. "Bugünü kaydet" ile başla.',
                  style: theme.bodySmall?.copyWith(
                    color: AppColors.textMuted(AppColors.textPrimary),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final (entry, template) = list[i];
                return _SonGirisCard(
                  entry: entry,
                  template: template,
                  onTap: () => context.push('/entry/${entry.id}'),
                );
              },
            );
          },
          loading: () => ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _SonGirisPlaceholder(index: index),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Girişler yüklenemedi.',
              style: theme.bodySmall?.copyWith(
                color: AppColors.textMuted(AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SonGirisCard extends StatelessWidget {
  const _SonGirisCard({
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
    return raw.length > 35 ? '${raw.substring(0, 35)}...' : raw;
  }

  static String _dateStr(DateTime d) {
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${d.day} ${months[d.month - 1]}';
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color != null ? color.withValues(alpha: 0.15) : AppColors.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: color != null ? Border(left: BorderSide(color: color, width: 3)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                offset: const Offset(0, 1),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.labelMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$date · $preview',
                      style: theme.bodySmall?.copyWith(
                        color: AppColors.textMuted(AppColors.textPrimary),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color? _parseColor(String hex) {
    if (hex.length != 7 || !hex.startsWith('#')) return null;
    final r = int.tryParse(hex.substring(1, 3), radix: 16);
    final g = int.tryParse(hex.substring(3, 5), radix: 16);
    final b = int.tryParse(hex.substring(5, 7), radix: 16);
    if (r == null || g == null || b == null) return null;
    return Color.fromARGB(255, r, g, b);
  }
}

class _SonGirisPlaceholder extends StatelessWidget {
  const _SonGirisPlaceholder({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final placeholders = [
      ('🤿', 'Dalış', '12 Mart', 'Sığ su, 8m...'),
      ('📚', 'Kitap', '11 Mart', 'Bölüm 3\'ü bitirdim...'),
      ('🎾', 'Tenis', '10 Mart', 'Maç 6-4, 6-3...'),
    ];
    final (emoji, title, date, preview) = placeholders[index];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 1),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date · $preview',
                  style: theme.bodySmall?.copyWith(
                    color: AppColors.textMuted(AppColors.textPrimary),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

