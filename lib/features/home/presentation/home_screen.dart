import 'dart:ui';
import 'dart:math' as math;

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
              final panelTopGap = (c.maxHeight * 0.06).clamp(36.0, 80.0);
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(firstName: firstName, email: auth.email),
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
                        SizedBox(height: panelTopGap),
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

Future<void> _showDefaultTemplatePicker(BuildContext context, WidgetRef ref) async {
  final templates = await ref.read(journalTemplatesProvider.future);
  final currentId = await ref.read(defaultTemplateIdProvider.future);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final maxH = MediaQuery.of(ctx).size.height * 0.6;
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(maxHeight: maxH),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Varsayılan şablon',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Serbest (metin alanı)', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                          trailing: currentId == null ? Icon(Icons.check_rounded, color: Colors.white.withValues(alpha: 0.9), size: 22) : null,
                          onTap: () async {
                            await ref.read(defaultTemplateNotifierProvider).setDefaultTemplateId(null);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Varsayılan şablon: Serbest'), behavior: SnackBarBehavior.floating),
                              );
                            }
                          },
                        ),
                        ...templates.map((t) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(t.icon, style: const TextStyle(fontSize: 20)),
                          title: Text(t.name, style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                          trailing: currentId == t.id ? Icon(Icons.check_rounded, color: Colors.white.withValues(alpha: 0.9), size: 22) : null,
                          onTap: () async {
                            await ref.read(defaultTemplateNotifierProvider).setDefaultTemplateId(t.id);
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Varsayılan şablon: ${t.name}'), behavior: SnackBarBehavior.floating),
                              );
                            }
                          },
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.firstName, required this.email});
  final String firstName;
  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        GestureDetector(
          onTap: () => _showProfileSheet(context, ref),
          child: ClipOval(
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
        ),
      ],
    );
  }

  Future<void> _showProfileSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    email ?? 'Bilinmeyen hesap',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.tune_rounded, color: Colors.white.withValues(alpha: 0.8), size: 22),
                    title: Text(
                      'Varsayılan Şablon',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showDefaultTemplatePicker(context, ref);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout_rounded, color: Colors.red.withValues(alpha: 0.9), size: 22),
                    title: Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.red.withValues(alpha: 0.9), fontSize: 15),
                    ),
                    onTap: () async {
                      await ref.read(authNotifierProvider.notifier).logout();
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
              _QuickEntryButton(),
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

class _QuickEntryButton extends ConsumerWidget {
  const _QuickEntryButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultIdAsync = ref.watch(defaultTemplateIdProvider);
    final templatesAsync = ref.watch(journalTemplatesProvider);
    String? defaultLabel;
    final defaultId = defaultIdAsync.valueOrNull;
    if (defaultId != null && defaultId > 0) {
      final list = templatesAsync.valueOrNull ?? [];
      for (final t in list) {
        if (t.id == defaultId) {
          defaultLabel = '${t.icon} ${t.name}';
          break;
        }
      }
    }

    return InkWell(
      onTap: () async {
        final id = await ref.read(defaultTemplateIdProvider.future);
        if (context.mounted) {
          if (id != null && id > 0) {
            context.pushNamed('entryNew', queryParameters: {'templateId': '$id'});
          } else {
            context.pushNamed('entryNew');
          }
        }
      },
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bugünü kaydet',
                    style: TextStyle(
                      color: AppColors.textOnGlassPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (defaultLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      defaultLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
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
    final usageAsync = ref.watch(templateUsageCountProvider);
    final usage = usageAsync.valueOrNull ?? <int, int>{};
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final onHome = list.take(2).toList();
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
                children: [
                  ...onHome.map((t) {
                    final count = usage[t.id] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () => context.pushNamed(
                          'entryNew',
                          queryParameters: {'templateId': '${t.id}'},
                        ),
                        onLongPress: () => _showTemplatePreview(context, t.id, t),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 88,
                          height: 80,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.icon, style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        t.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (count > 0) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '$count giriş',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.35),
                                            fontSize: 9,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => _showAddTemplateSheet(context, list),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 88,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Colors.white.withValues(alpha: 0.9),
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Şablon ekle',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static void _showAddTemplateSheet(
    BuildContext context,
    List<JournalTemplate> allTemplates,
  ) {
    final rest = allTemplates.skip(2).toList();
    final screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: BoxConstraints(maxHeight: 0.6 * screenHeight),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.9)),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Şablonlar',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Tüm şablonlar veya yeni oluştur',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (rest.isNotEmpty) ...[
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                ...rest.map((t) {
                                  return SizedBox(
                                    width: 88,
                                    height: 80,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        context.pushNamed(
                                          'entryNew',
                                          queryParameters: {'templateId': '${t.id}'},
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.13),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(t.icon, style: const TextStyle(fontSize: 22)),
                                            const SizedBox(height: 4),
                                            Expanded(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  t.name,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.7),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 14),
                          ],
                          InkWell(
                            onTap: () {
                              Navigator.of(ctx).pop();
                              context.pushNamed('templateBuilder');
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.11),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Yeni şablon oluştur',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTemplatePreview(
    BuildContext context,
    int templateId,
    JournalTemplate template,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final asyncFields = ref.watch(templateFieldsProvider(templateId));
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(template.icon, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              template.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      asyncFields.when(
                        loading: () => Text(
                          'Yukleniyor...',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        error: (error, stackTrace) => Text(
                          'Alanlar yuklenemedi.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        data: (fields) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${fields.length} alan iceriyor',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.74)),
                            ),
                            const SizedBox(height: 10),
                            ...fields.map(
                              (f) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    Text(_templateFieldIcon(f.fieldType)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        f.label,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    if (f.isRequired)
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.pushNamed(
                            'entryNew',
                            queryParameters: {'templateId': '$templateId'},
                          );
                        },
                        child: const Text('Basla ->'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
    final freeText = (entry.freeText ?? '').trim();
    final title = template?.name ??
        ((entry.mood ?? '').isNotEmpty
            ? '${entry.mood} ${_timeStr(entry.createdAt)}'
            : (freeText.isNotEmpty
                ? freeText.substring(0, math.min(freeText.length, 20))
                : 'Giriş'));
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
                    title,
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

String _timeStr(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

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

String _templateFieldIcon(String type) {
  switch (type) {
    case 'number':
      return '🔢';
    case 'slider':
      return '📊';
    case 'text':
      return '📝';
    case 'long_text':
      return '📄';
    case 'select':
      return '◉';
    case 'tags':
      return '🏷️';
    case 'location':
      return '📍';
    case 'photo':
      return '📸';
    case 'weather':
      return '🌤️';
    default:
      return '•';
  }
}
