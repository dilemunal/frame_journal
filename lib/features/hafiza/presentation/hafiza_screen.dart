import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../entry/presentation/widgets/glass_card.dart';

const _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

List<(String, List<(AppEntry, JournalTemplate?)>)> _groupEntriesByDate(
  List<(AppEntry, JournalTemplate?)> list,
) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekday = now.weekday;
  final mondayThisWeek = todayStart.subtract(Duration(days: weekday - 1));
  final mondayLastWeek = mondayThisWeek.subtract(const Duration(days: 7));

  final today = <(AppEntry, JournalTemplate?)>[];
  final thisWeek = <(AppEntry, JournalTemplate?)>[];
  final lastWeek = <(AppEntry, JournalTemplate?)>[];
  final byMonth = <String, List<(AppEntry, JournalTemplate?)>>{};

  for (final item in list) {
    final d = item.$1.createdAt;
    final dayStart = DateTime(d.year, d.month, d.day);
    if (dayStart == todayStart) {
      today.add(item);
    } else if (!dayStart.isBefore(mondayThisWeek) && dayStart.isBefore(todayStart)) {
      thisWeek.add(item);
    } else if (!dayStart.isBefore(mondayLastWeek) && dayStart.isBefore(mondayThisWeek)) {
      lastWeek.add(item);
    } else {
      final key = '${_monthNames[d.month - 1]} ${d.year}';
      byMonth.putIfAbsent(key, () => []).add(item);
    }
  }

  final result = <(String, List<(AppEntry, JournalTemplate?)>)>[];
  if (today.isNotEmpty) result.add(('Bugün', today));
  if (thisWeek.isNotEmpty) result.add(('Bu Hafta', thisWeek));
  if (lastWeek.isNotEmpty) result.add(('Geçen Hafta', lastWeek));
  final monthKeys = byMonth.keys.toList();
  monthKeys.sort((a, b) {
    final pa = _parseMonthKey(a);
    final pb = _parseMonthKey(b);
    if (pa == null || pb == null) {
      return 0;
    }
    if (pa.$1 != pb.$1) {
      return pb.$1.compareTo(pa.$1);
    }
    return pb.$2.compareTo(pa.$2);
  });
  for (final k in monthKeys) {
    result.add((k, byMonth[k]!));
  }
  return result;
}

(int, int)? _parseMonthKey(String key) {
  final parts = key.split(' ');
  if (parts.length != 2) return null;
  final monthIndex = _monthNames.indexOf(parts[0]);
  final year = int.tryParse(parts[1]);
  if (monthIndex < 0 || year == null) return null;
  return (year, monthIndex);
}

class _OnThisDaySliver extends ConsumerWidget {
  const _OnThisDaySliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(pastYearsTodayEntriesProvider);
    return async.when(
      data: (list) {
        if (list.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  '📅 Bu gün, geçmiş yıllarda',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
              ...list.map((e) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: InkWell(
                  onTap: () => context.push('/entry/${e.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: GlassCard(
                    opacity: 0.10,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    borderRadius: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${e.createdAt.year}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            (e.freeText ?? e.title ?? '—').trim().isEmpty
                                ? '—'
                                : (e.freeText ?? e.title ?? '').trim().length > 80
                                    ? '${(e.freeText ?? e.title ?? '').trim().substring(0, 80)}…'
                                    : (e.freeText ?? e.title ?? '').trim(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class HafizaScreen extends ConsumerStatefulWidget {
  const HafizaScreen({super.key});

  @override
  ConsumerState<HafizaScreen> createState() => _HafizaScreenState();
}

class _HafizaScreenState extends ConsumerState<HafizaScreen> {
  /// null = Tümü, -1 = Serbest, >0 = template id
  int? _selectedFilterId;
  int _page = 0;
  bool _loadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 && pos.maxScrollExtent > 0) {
      setState(() {
        _page++;
        _loadingMore = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final usedTemplates = ref.watch(usedTemplatesProvider);
    final limit = 20 * (_page + 1);
    final async = ref.watch(filteredMemoryEntriesProvider((_selectedFilterId, limit)));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
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
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                  child: Text(
                    'Geçmiş girişlerin, anılarını taşıyan kartlar.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              usedTemplates.when(
                data: (chips) => SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _FilterChip(
                          label: 'Tümü',
                          icon: null,
                          selected: _selectedFilterId == null,
                          onTap: () => setState(() {
                            _selectedFilterId = null;
                            _page = 0;
                          }),
                        ),
                        ...chips.map(
                          (c) => _FilterChip(
                            label: c.label,
                            icon: c.icon,
                            selected: _selectedFilterId == c.filterId,
                            onTap: () => setState(() {
                              _selectedFilterId = c.filterId;
                              _page = 0;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (e, st) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _OnThisDaySliver(),
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
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _loadingMore = false);
                  });
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
                  final hasMore = list.length >= limit;
                  final groups = _groupEntriesByDate(list);
                  final totalCount = groups.fold<int>(
                        0,
                        (sum, g) => sum + 1 + g.$2.length,
                      ) + (hasMore ? 1 : 0);
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        int offset = 0;
                        for (final (title, items) in groups) {
                          if (index == offset) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            );
                          }
                          offset++;
                          for (var i = 0; i < items.length; i++) {
                            if (index == offset) {
                              final (entry, template) = items[i];
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                                child: _Card(
                                  entry: entry,
                                  template: template,
                                  onTap: () => context.push('/entry/${entry.id}'),
                                )
                                    .animate()
                                    .fadeIn(
                                      delay: Duration(milliseconds: 50 * (offset + i)),
                                      duration: 280.ms,
                                    )
                                    .slideY(
                                      begin: 0.08,
                                      end: 0,
                                      delay: Duration(milliseconds: 50 * (offset + i)),
                                      duration: 280.ms,
                                    ),
                              );
                            }
                            offset++;
                          }
                        }
                        if (hasMore && index == totalCount - 1) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      childCount: totalCount,
                    ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: 0.95)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null && icon!.isNotEmpty)
                  Text(icon!, style: TextStyle(fontSize: 14, color: selected ? Colors.black87 : Colors.white)),
                if (icon != null && icon!.isNotEmpty) const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? Colors.black87 : Colors.white,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
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
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: BoxDecoration(
                  color: tint != null
                      ? tint.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template?.name ?? 'Giriş',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _date(entry.createdAt),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.60),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (tint != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    color: tint,
                  ),
                ),
            ],
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
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
