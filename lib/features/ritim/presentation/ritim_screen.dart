import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/rhythm_provider.dart';

class RitimScreen extends ConsumerWidget {
  const RitimScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rhythmCompletionsProvider);
    final notifier = ref.read(rhythmCompletionsProvider.notifier);
    final completed = async.valueOrNull ?? <String>{};

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Ritim',
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
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                  child: Text(
                    'Bugün hangi ritim bloklarını tamamladın?',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.50)),
                  ),
                ),
              ),
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
                      'Ritim yüklenemedi.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.60)),
                    ),
                  ),
                ),
                data: (_) => SliverList.builder(
                  itemCount: kRhythmSlotKeys.length,
                  itemBuilder: (context, index) {
                    final key = kRhythmSlotKeys[index];
                    final label = kRhythmSlotLabels[key] ?? key;
                    final isDone = completed.contains(key);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _RhythmCard(
                        label: label,
                        slotKey: key,
                        completed: isDone,
                        onToggle: () => notifier.toggle(key),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 70 * index),
                            duration: 280.ms,
                          )
                          .slideY(
                            begin: 0.08,
                            end: 0,
                            delay: Duration(milliseconds: 70 * index),
                            duration: 280.ms,
                          ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RhythmCard extends StatelessWidget {
  const _RhythmCard({
    required this.label,
    required this.slotKey,
    required this.completed,
    required this.onToggle,
  });

  final String label;
  final String slotKey;
  final bool completed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: completed
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: completed ? 0.24 : 0.13),
                  ),
                  child: Icon(
                    completed ? Icons.check_rounded : _iconFor(slotKey),
                    color: Colors.white.withValues(alpha: completed ? 0.95 : 0.50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: completed ? 0.95 : 0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Checkbox(
                  value: completed,
                  onChanged: (_) => onToggle(),
                  activeColor: Colors.white,
                  checkColor: const Color(0xFF2A2A2A),
                ),
              ],
            ),
          ),
        ),
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

