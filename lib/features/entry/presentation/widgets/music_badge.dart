import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Placeholder: audio_query veya method channel ile implement edilecek.
class MusicBadge extends StatelessWidget {
  const MusicBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Opacity(
      opacity: 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.music_note_rounded),
            color: AppColors.textMuted(AppColors.textPrimary),
          ),
          Text(
            'Yakında',
            style: theme.labelSmall?.copyWith(
              color: AppColors.textMuted(AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
