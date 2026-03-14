import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

String moodLabel(double v) {
  final x = v.clamp(0.0, 1.0);
  if (x < 0.2) return '😴 Yorgunum';
  if (x < 0.4) return '😔 Zor bir gün';
  if (x < 0.6) return '😌 İdare eder';
  if (x < 0.8) return '😊 İyi hissediyorum';
  return '🔥 Muhteşem!';
}

class MoodBar extends StatefulWidget {
  const MoodBar({super.key, required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<MoodBar> createState() => _MoodBarState();
}

class _MoodBarState extends State<MoodBar> with SingleTickerProviderStateMixin {
  late final AnimationController _hintController;
  late final Animation<double> _hintAnim;

  static const _stops = [0.0, 0.25, 0.5, 0.75, 1.0];
  static const _emojis = ['😴', '😔', '😌', '😊', '🔥'];

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );
    _hintAnim =
        TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.3), weight: 1),
            TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.7), weight: 1),
            TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.5), weight: 1),
          ]).animate(
            CurvedAnimation(
              parent: _hintController,
              curve: Curves.easeInOutCubic,
            ),
          )
          ..addListener(() {
            if (_hintController.isAnimating) widget.onChanged(_hintAnim.value);
          });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _hintController.forward(),
    );
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  void _updateFromPosition(Offset local, double trackWidth, double leftPad) {
    if (_hintController.isAnimating) _hintController.stop();
    final t = ((local.dx - leftPad) / trackWidth).clamp(0.0, 1.0);
    widget.onChanged(t);
  }

  @override
  Widget build(BuildContext context) {
    final label = moodLabel(widget.value);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
              .animate(key: ValueKey(label))
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.2, end: 0, duration: 200.ms),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final v = widget.value.clamp(0.0, 1.0);
              final thumbX = v * width;

              return GestureDetector(
                onPanUpdate: (d) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box != null) {
                    final local = box.globalToLocal(d.globalPosition);
                    _updateFromPosition(local, width, 0);
                  }
                },
                onTapDown: (d) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box != null) {
                    final local = box.globalToLocal(d.globalPosition);
                    _updateFromPosition(local, width, 0);
                  }
                },
                child: SizedBox(
                  height: 42,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 28,
                        height: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [_cold, _warm],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: thumbX - 12,
                        top: 16,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: moodColorFromValue(widget.value),
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                          child: Icon(
                            Icons.swipe,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_emojis.length, (i) {
                          final stop = _stops[i];
                          final selected = (widget.value - stop).abs() < 0.13;
                          return GestureDetector(
                            onTap: () {
                              if (_hintController.isAnimating)
                                _hintController.stop();
                              widget.onChanged(stop);
                            },
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: selected ? 1.3 : 1.0,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: selected ? 1 : 0.5,
                                child: Text(
                                  _emojis[i],
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
