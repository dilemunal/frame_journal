import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_theme.dart';

/// Tek satır: 📍 Yer   HH:mm  •  🌧️ 14°C Açıklama. Saat ekran açılışında sabitlenir.
class AtmosphereStrip extends ConsumerStatefulWidget {
  const AtmosphereStrip({super.key});

  @override
  ConsumerState<AtmosphereStrip> createState() => _AtmosphereStripState();
}

class _AtmosphereStripState extends ConsumerState<AtmosphereStrip> {
  late final String _fixedTime;

  @override
  void initState() {
    super.initState();
    _fixedTime = _formatTime(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(atmosphereProvider);

    return async.when(
      data: (atm) {
        if (atm == null) return const SizedBox.shrink();
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: AppColors.surface,
            child: Row(
              children: [
                Text(
                  '📍 ${atm.location.placeName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted(AppColors.textPrimary),
                        fontSize: 12,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                Text(
                  _fixedTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted(AppColors.textPrimary),
                        fontSize: 12,
                      ),
                ),
                if (atm.weather != null) ...[
                  Text(
                    '  •  ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted(AppColors.textPrimary),
                          fontSize: 12,
                        ),
                  ),
                  Text(
                    '${atm.weather!.emoji} ${atm.weather!.temp}°C ${atm.weather!.description}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted(AppColors.textPrimary),
                          fontSize: 12,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
