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

  Widget _buildStrip(BuildContext context, {String? location, String? weatherPart}) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.textMuted(AppColors.textPrimary),
      fontSize: 12,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          if (location != null && location.isNotEmpty)
            Expanded(
              child: Text(
                '📍 $location',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (location != null && location.isNotEmpty) const SizedBox(width: 8),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(atmosphereProvider);

    return async.when(
      data: (atm) {
        if (atm != null) {
          final weatherPart = atm.weather != null
              ? '${atm.weather!.emoji} ${atm.weather!.temp}°C ${atm.weather!.description}'
              : null;
          return AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: _buildStrip(
              context,
              location: atm.location.placeName,
              weatherPart: weatherPart,
            ),
          );
        }
        // Konum/hava alınamadı: yine de saat göster (izin kapalı veya API anahtarı yok)
        return _buildStrip(
          context,
          location: 'Konum kapalı',
          weatherPart: null,
        );
      },
      loading: () => _buildStrip(
        context,
        location: 'Konum alınıyor...',
        weatherPart: null,
      ),
      error: (_, __) => _buildStrip(
        context,
        location: 'Konum alınamadı',
        weatherPart: null,
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
