import 'package:flutter/material.dart';

class DraftRecoverySheet extends StatelessWidget {
  const DraftRecoverySheet({
    super.key,
    required this.previewText,
    required this.onContinue,
    required this.onDiscard,
  });

  final String previewText;
  final VoidCallback onContinue;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Yarım kalan bir şey var...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              previewText.length > 40
                  ? '${previewText.substring(0, 40)}...'
                  : previewText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onContinue,
                    child: const Text('Devam Et'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onDiscard,
                    child: const Text('Sil, Başla'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
