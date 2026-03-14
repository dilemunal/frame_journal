import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../entry/presentation/widgets/glass_card.dart';
import '../application/rhythm_provider.dart';

/// Haftanın gün harfleri: P S Ç P C C P (Pazartesi–Pazar).
const List<String> _weekdayLetters = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];

/// Mood emoji → sayı (grafik için). null → -1 (gösterilmez).
int _moodToValue(String? emoji) {
  if (emoji == null || emoji.isEmpty) return -1;
  switch (emoji) {
    case '😴':
      return 0;
    case '😔':
      return 2;
    case '😌':
      return 5;
    case '😊':
      return 8;
    case '🔥':
      return 10;
    default:
      return -1;
  }
}

String _formatTime(DateTime d) {
  return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

String _dateKey(DateTime d) {
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class RitimScreen extends ConsumerWidget {
  const RitimScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last30 = ref.watch(last30DaysEntryCountProvider);
    final last14Mood = ref.watch(last14DaysMoodProvider);
    final hourDist = ref.watch(hourDistributionProvider);
    final thisWeek = ref.watch(thisWeekEntriesProvider);
    final pastToday = ref.watch(pastYearsTodayEntriesProvider);
    final completions = ref.watch(rhythmCompletionsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: last30.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (e, st) => Center(
              child: Text(
                'Ritim yüklenemedi.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            data: (countByDay) {
              final daysWithEntries =
                  countByDay.values.where((c) => c > 0).length;
              final subtitle = countByDay.isEmpty
                  ? 'Yazma alışkanlıkların burada şekillenecek.'
                  : 'Son 30 günde $daysWithEntries gün yazdın.';

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ritim',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _SectionBuHafta(thisWeek: thisWeek)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.06, end: 0, duration: 300.ms),
                    const SizedBox(height: 20),

                    _SectionSon30Gun(countByDay: countByDay)
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 300.ms)
                        .slideY(begin: 0.06, end: 0, delay: 80.ms, duration: 300.ms),
                    const SizedBox(height: 20),

                    _SectionNeZamanYaziyorsun(hourDist: hourDist)
                        .animate()
                        .fadeIn(delay: 160.ms, duration: 300.ms)
                        .slideY(begin: 0.06, end: 0, delay: 160.ms, duration: 300.ms),
                    const SizedBox(height: 20),

                    last14Mood.when(
                      data: (moodList) {
                        final hasAny =
                            moodList.any((e) => e.$2 != null && e.$2!.isNotEmpty);
                        if (!hasAny) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _SectionRuhHaliTrendi(moodList: moodList)
                              .animate()
                              .fadeIn(delay: 240.ms, duration: 300.ms)
                              .slideY(begin: 0.06, end: 0, delay: 240.ms, duration: 300.ms),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (e, st) => const SizedBox.shrink(),
                    ),

                    pastToday.when(
                      data: (list) {
                        if (list.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _SectionGecmistenBugun(entries: list.take(2).toList())
                              .animate()
                              .fadeIn(delay: 320.ms, duration: 300.ms)
                              .slideY(begin: 0.06, end: 0, delay: 320.ms, duration: 300.ms),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (e, st) => const SizedBox.shrink(),
                    ),

                    completions.when(
                      data: (map) => _SectionBugununRitmi(
                            completions: map,
                            onSlotTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bu slot bir entry kaydedilince otomatik tamamlanır.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 300.ms)
                              .slideY(begin: 0.06, end: 0, delay: 400.ms, duration: 300.ms),
                      loading: () => const SizedBox.shrink(),
                      error: (e, st) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionBuHafta extends StatelessWidget {
  const _SectionBuHafta({required this.thisWeek});

  final AsyncValue<Map<DateTime, (int, String?)>> thisWeek;

  @override
  Widget build(BuildContext context) {
    return thisWeek.when(
      data: (map) {
        final now = DateTime.now();
        final todayKey = _dateKey(now);
        final monday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return GlassCard(
          opacity: 0.10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final d = monday.add(Duration(days: i));
                  final key = _dateKey(d);
                  final pair = map[d] ?? (0, null);
                  final count = pair.$1;
                  final mood = pair.$2;
                  final isToday = key == todayKey;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _weekdayLetters[i],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: isToday ? 28 : 24,
                        height: isToday ? 28 : 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: count > 0
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.transparent,
                          border: Border.all(
                            color: count > 0
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.2),
                            width: isToday ? 1.5 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: count > 0
                            ? Text(
                                count > 1 ? '$count' : '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                      if (mood != null && mood.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          mood,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
      loading: () => GlassCard(opacity: 0.10, child: const SizedBox(height: 80)),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _SectionSon30Gun extends StatelessWidget {
  const _SectionSon30Gun({required this.countByDay});

  final Map<String, int> countByDay;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final list = <int>[];
    for (var i = 0; i < 30; i++) {
      final d = now.subtract(Duration(days: 29 - i));
      final key = _dateKey(d);
      list.add(countByDay[key] ?? 0);
    }
    return GlassCard(
      opacity: 0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son 30 gün',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          LayoutGrid30(
            counts: list,
          ),
        ],
      ),
    );
  }
}

class LayoutGrid30 extends StatelessWidget {
  const LayoutGrid30({super.key, required this.counts});

  final List<int> counts;

  static const double dotSize = 10;
  static const double gap = 8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List.generate(counts.length, (i) {
            final c = counts[i];
            double opacity = 0.15;
            if (c > 0) {
              if (c == 1) {
                opacity = 0.5;
              } else if (c == 2) {
                opacity = 0.7;
              } else {
                opacity = 0.95;
              }
            }
            return Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SectionNeZamanYaziyorsun extends StatelessWidget {
  const _SectionNeZamanYaziyorsun({required this.hourDist});

  final AsyncValue<Map<String, int>> hourDist;

  @override
  Widget build(BuildContext context) {
    return hourDist.when(
      data: (map) {
        final morning = map['morning'] ?? 0;
        final afternoon = map['afternoon'] ?? 0;
        final night = map['night'] ?? 0;
        final total = morning + afternoon + night;
        final slots = [
          ('Sabah', '☀️', morning),
          ('Öğleden sonra', '🌤️', afternoon),
          ('Gece', '🌙', night),
        ];
        final maxCount =
            [morning, afternoon, night].reduce((a, b) => a > b ? a : b);
        final isTie = total > 0 &&
            (morning == afternoon && afternoon == night ||
                (morning == maxCount && afternoon == maxCount) ||
                (afternoon == maxCount && night == maxCount) ||
                (morning == maxCount && night == maxCount));

        String bottomText;
        if (total == 0) {
          bottomText = 'Henüz yazı yok.';
        } else if (isTie) {
          bottomText = 'Her saatte yazıyorsun.';
        } else {
          if (morning >= afternoon && morning >= night) {
            bottomText = 'Genellikle Sabah yazıyorsun.';
          } else if (afternoon >= morning && afternoon >= night) {
            bottomText = 'Genellikle Öğleden sonra yazıyorsun.';
          } else {
            bottomText = 'Genellikle Gece yazıyorsun.';
          }
        }

        return GlassCard(
          opacity: 0.10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: slots.map((s) {
                  final pct = total > 0 ? (s.$3 / total) : 0.0;
                  final isMax = total > 0 && s.$3 == maxCount;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.$2, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            s.$1,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            total > 0 ? '${(pct * 100).round()}%' : '0%',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 80,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: SizedBox(
                                height: 80 * pct.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.white.withValues(
                                            alpha: isMax ? 0.95 : 0.7),
                                        Colors.white.withValues(
                                            alpha: isMax ? 0.5 : 0.35),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                bottomText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => GlassCard(opacity: 0.10, child: const SizedBox(height: 140)),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _SectionRuhHaliTrendi extends StatelessWidget {
  const _SectionRuhHaliTrendi({required this.moodList});

  final List<(DateTime, String?)> moodList;

  @override
  Widget build(BuildContext context) {
    final values =
        moodList.map((e) => _moodToValue(e.$2)).toList();
    return GlassCard(
      opacity: 0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ruh hali trendi',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                height: 80,
                width: constraints.maxWidth,
                child: CustomPaint(
                  painter: _MoodLineChartPainter(values: values),
                  size: Size(constraints.maxWidth, 80),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '14 gün önce',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              Text(
                'Bugün',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodLineChartPainter extends CustomPainter {
  _MoodLineChartPainter({required this.values});

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final valid = values.where((v) => v >= 0).toList();
    if (valid.isEmpty) return;
    final count = values.length;
    if (count < 2) return;
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final stepX = w / (count - 1);
    double x(int i) => i * stepX;
    double y(int v) => h - (v / 10.0) * h;
    int lastValidIndex = -1;
    for (var i = 0; i < count; i++) {
      final v = values[i];
      if (v < 0) {
        lastValidIndex = -1;
        continue;
      }
      final px = x(i);
      final py = y(v);
      canvas.drawCircle(Offset(px, py), 4, dotPaint);
      if (lastValidIndex >= 0) {
        final prevX = x(lastValidIndex);
        final prevY = y(values[lastValidIndex]);
        canvas.drawLine(Offset(prevX, prevY), Offset(px, py), stroke);
      }
      lastValidIndex = i;
    }
  }

  @override
  bool shouldRepaint(covariant _MoodLineChartPainter old) =>
      old.values != values;
}

class _SectionGecmistenBugun extends StatelessWidget {
  const _SectionGecmistenBugun({required this.entries});

  final List<AppEntry> entries;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opacity: 0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geçmişten bugün 🕰️',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ...entries.map((e) {
            final preview = (e.freeText ?? e.title ?? '').trim();
            final short = preview.length > 60 ? '${preview.substring(0, 60)}…' : preview;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => context.push('/entry/${e.id}'),
                borderRadius: BorderRadius.circular(12),
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
                        short.isEmpty ? '—' : short,
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
            );
          }),
        ],
      ),
    );
  }
}

class _SectionBugununRitmi extends StatelessWidget {
  const _SectionBugununRitmi({
    required this.completions,
    required this.onSlotTap,
  });

  final Map<String, DateTime> completions;
  final VoidCallback onSlotTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      opacity: 0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...kRhythmSlotKeys.map((key) {
            final completedAt = completions[key];
            final label = kRhythmSlotLabels[key] ?? key;
            final isDone = completedAt != null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: onSlotTap,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.transparent,
                        border: Border.all(
                          color: isDone
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isDone
                          ? null
                          : Icon(
                              _iconFor(key),
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: isDone
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.white.withValues(alpha: 0.3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isDone)
                            Text(
                              "${_formatTime(completedAt)}'te yazdın",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static IconData _iconFor(String slotKey) {
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
}
