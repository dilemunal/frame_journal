import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final firstName = _firstNameFromEmail(auth.email);
    final now = DateTime.now();
    final greeting = greetingForHour(now.hour);
    final dateText = _formatDateTr(now);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(firstName: firstName),
                        const SizedBox(height: 14),
                        _WeekStrip(now: now),
                        const SizedBox(height: 24),
                        Text(
                          greeting,
                          style: TextStyle(
                            color: AppColors.textOnGlassPrimary,
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                            height: 1.05,
                            letterSpacing: -0.7,
                          ),
                        )
                            .animate()
                            .fadeIn(
                              duration: 450.ms,
                              delay: 100.ms,
                              curve: Curves.easeOut,
                            )
                            .slideY(
                              begin: 0.05,
                              end: 0,
                              duration: 450.ms,
                              delay: 100.ms,
                            ),
                        const SizedBox(height: 6),
                        Text(
                          dateText,
                          style: TextStyle(
                            color: AppColors.textOnGlassMuted,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: c.maxHeight * 0.24),
                        _BottomPanel(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.firstName});
  final String firstName;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        firstName.isEmpty ? 'Merhaba' : 'Merhaba, $firstName';
    return Row(
      children: [
        Expanded(
          child: Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textOnGlassMuted,
              fontSize: 14,
            ),
          ),
        ),
        ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.glassFill12,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(Icons.person, color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    const days = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
    final today = now.weekday - 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final selected = i == today;
        return Column(
          children: [
            Text(
              days[i],
              style: TextStyle(
                color: selected
                    ? AppColors.textOnGlassPrimary
                    : Colors.white.withValues(alpha: 0.4),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Colors.white : Colors.transparent,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _BottomPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.glassFill13,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuickEntryButton(
                onTap: () => context.pushNamed('entryNew'),
              ),
              const SizedBox(height: 16),
              const _TemplateSection(),
              const SizedBox(height: 14),
              const _RecentSection(),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOut)
        .fadeIn(duration: 500.ms);
  }
}

class _QuickEntryButton extends StatelessWidget {
  const _QuickEntryButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Bugünü kaydet',
                style: TextStyle(
                  color: AppColors.textOnGlassPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.9)),
          ],
        ),
      ),
    );
  }
}

class _TemplateSection extends ConsumerWidget {
  const _TemplateSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(journalTemplatesProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Şablonlar',
              style: TextStyle(
                color: AppColors.textOnGlassMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: list.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => context.pushNamed(
                        'entryNew',
                        queryParameters: {'templateId': '${t.id}'},
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 88,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(t.icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 6),
                            Text(
                              t.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecentSection extends ConsumerWidget {
  const _RecentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentEntriesProvider);
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son girişler',
              style: TextStyle(color: AppColors.textOnGlassMuted, fontSize: 13),
            ),
            const SizedBox(height: 10),
            ...List.generate(list.length, (index) {
              final (entry, template) = list[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecentCard(
                  entry: entry,
                  template: template,
                  onTap: () => context.push('/entry/${entry.id}'),
                )
                    .animate()
                    .fadeIn(duration: 320.ms, delay: Duration(milliseconds: 80 * index))
                    .slideX(
                      begin: 0.06,
                      end: 0,
                      duration: 320.ms,
                      delay: Duration(milliseconds: 80 * index),
                    ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({
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
        : (preview.length > 85 ? '${preview.substring(0, 85)}...' : preview);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tint != null
              ? tint.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: tint != null
                ? BorderSide(color: tint, width: 3)
                : BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template?.name ?? 'Giriş',
                    style: TextStyle(
                      color: AppColors.textOnGlassPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.75)),
          ],
        ),
      ),
    );
  }
}

String _firstNameFromEmail(String? email) {
  if (email == null || email.isEmpty) return '';
  final part = email.split('@').first;
  if (part.isEmpty) return '';
  return part.length > 1
      ? '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}'
      : part.toUpperCase();
}

Color? _parseHexColor(String hex) {
  if (hex.length != 7 || !hex.startsWith('#')) return null;
  final r = int.tryParse(hex.substring(1, 3), radix: 16);
  final g = int.tryParse(hex.substring(3, 5), radix: 16);
  final b = int.tryParse(hex.substring(5, 7), radix: 16);
  if (r == null || g == null || b == null) return null;
  return Color.fromARGB(255, r, g, b);
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
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
