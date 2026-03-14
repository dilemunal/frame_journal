import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import 'glass_card.dart';

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

  Widget _buildStrip(BuildContext context, String location, String? weatherPart) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 13,
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderRadius: 16,
        opacity: 0.14,
        child: Row(
          children: [
            Expanded(
              child: Text(
                '📍 $location',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(_fixedTime, style: style),
            if (weatherPart != null && weatherPart.isNotEmpty) ...[
              Text('  •  ', style: style),
              Expanded(
                child: Text(
                  weatherPart,
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(atmosphereProvider);

    return async.when(
      data: (atm) => Visibility(
        visible: atm != null,
        maintainState: true,
        child: atm == null
            ? const SizedBox.shrink()
            : AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 300),
                child: _buildStrip(
                  context,
                  atm.location.placeName,
                  atm.weather != null
                      ? '${atm.weather!.emoji} ${atm.weather!.temp}°C ${atm.weather!.description}'
                      : null,
                ),
              ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
