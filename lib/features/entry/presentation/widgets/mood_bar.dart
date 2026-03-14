import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

const Color _cold = Color(0xFF8FA5BA);
const Color _warm = Color(0xFFD4874E);

Color moodColorFromValue(double value) =>
    Color.lerp(_cold, _warm, value.clamp(0.0, 1.0))!;

/// Mood değerinden emoji.
String moodEmoji(double v) {
  final x = v.clamp(0.0, 1.0);
  if (x < 0.2) return '😴';
  if (x < 0.4) return '😔';
  if (x < 0.6) return '😌';
  if (x < 0.8) return '😊';
  return '🔥';
}

/// 0.0 (soğuk) → 1.0 (sıcak) gradient çizgi, sürüklenebilir daire.
class MoodBar extends StatefulWidget {
  const MoodBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<MoodBar> createState() => _MoodBarState();
}

class _MoodBarState extends State<MoodBar> {
  void _updateFromPosition(Offset local, double trackWidth, double leftPad) {
    final t = ((local.dx - leftPad) / trackWidth).clamp(0.0, 1.0);
    widget.onChanged(t);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const emojiW = 24.0;
          final trackWidth = constraints.maxWidth - emojiW * 2;
          final leftPad = emojiW;
          final v = widget.value.clamp(0.0, 1.0);
          final thumbX = leftPad + v * trackWidth - 7;

          return GestureDetector(
            onPanUpdate: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final local = box.globalToLocal(d.globalPosition);
                _updateFromPosition(local, trackWidth, leftPad);
              }
            },
            onTapDown: (d) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final local = box.globalToLocal(d.globalPosition);
                _updateFromPosition(local, trackWidth, leftPad);
              }
            },
            child: Row(
              children: [
                Text(
                  '😴',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted(AppColors.textPrimary),
                  ),
                ),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 6,
                        height: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            gradient: const LinearGradient(
                              colors: [_cold, _warm],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: thumbX,
                        top: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: moodColorFromValue(widget.value),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '🔥',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted(AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
