import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';
import '../../../core/theme/app_theme.dart';

const _monthNames = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

class FilmRollScreen extends ConsumerWidget {
  const FilmRollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(filmRollFramesProvider);
    final templatesAsync = ref.watch(journalTemplatesProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Film Şeridi',
                      style: TextStyle(
                        color: AppColors.textOnGlassPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Günlük kareler — bir kareye dokun',
                      style: TextStyle(
                        color: AppColors.textOnGlassMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: async.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  error: (e, s) => Center(
                    child: Text(
                      'Yüklenemedi.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  data: (frames) {
                    if (frames.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_filter_rounded,
                              size: 56,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Henüz kare yok',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Giriş ekledikçe burada görünecek.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final templateMap = <int, JournalTemplate>{};
                    templatesAsync.whenData((list) {
                      for (final t in list) {
                        templateMap[t.id] = t;
                      }
                    });
                    return _FilmStrip(
                      frames: frames,
                      templateMap: templateMap,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilmStrip extends StatelessWidget {
  const _FilmStrip({
    required this.frames,
    required this.templateMap,
  });

  final List<(DateTime, AppEntry)> frames;
  final Map<int, JournalTemplate> templateMap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const frameWidth = 140.0;
        const frameHeight = 180.0;
        const spacing = 16.0;
        const padding = 20.0;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: padding,
            right: padding,
            top: (constraints.maxHeight - frameHeight) / 2,
            bottom: (constraints.maxHeight - frameHeight) / 2,
          ),
          itemCount: frames.length,
          itemBuilder: (context, index) {
            final (dayDate, entry) = frames[index];
            final template = entry.templateId != null
                ? templateMap[entry.templateId]
                : null;
            return Padding(
              padding: EdgeInsets.only(
                right: index < frames.length - 1 ? spacing : 0,
              ),
              child: _FilmFrame(
                dayDate: dayDate,
                entry: entry,
                template: template,
                width: frameWidth,
                height: frameHeight,
                onTap: () => context.push('/entry/${entry.id}'),
              ),
            )
                .animate()
                .fadeIn(
                  duration: 400.ms,
                  delay: (index * 50).ms,
                  curve: Curves.easeOut,
                )
                .slideX(
                  begin: 0.15,
                  end: 0,
                  duration: 400.ms,
                  delay: (index * 50).ms,
                  curve: Curves.easeOutCubic,
                );
          },
        );
      },
    );
  }
}

class _FilmFrame extends StatelessWidget {
  const _FilmFrame({
    required this.dayDate,
    required this.entry,
    required this.template,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final DateTime dayDate;
  final AppEntry entry;
  final JournalTemplate? template;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final day = dayDate.day;
    final month = _monthNames[dayDate.month - 1];
    final icon = template?.icon ?? '📝';
    final mood = entry.mood;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Perforation effect — top/bottom film edge
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 12,
                  child: CustomPaint(
                    painter: _PerforationPainter(
                      color: Colors.white.withValues(alpha: 0.08),
                      isTop: true,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 12,
                  child: CustomPaint(
                    painter: _PerforationPainter(
                      color: Colors.white.withValues(alpha: 0.08),
                      isTop: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 32,
                          fontWeight: FontWeight.w200,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        month,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                      if (mood != null && mood.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            mood,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 18,
                            ),
                          ),
                        ),
                    ],
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

class _PerforationPainter extends CustomPainter {
  _PerforationPainter({required this.color, required this.isTop});

  final Color color;
  final bool isTop;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const holeWidth = 6.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, isTop ? 2 : size.height - 6, holeWidth, 4),
        const Radius.circular(1),
      );
      canvas.drawRRect(rect, paint);
      x += holeWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
