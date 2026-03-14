import 'package:flutter/material.dart';

import 'glass_card.dart';

class KeyboardToolbar extends StatelessWidget {
  const KeyboardToolbar({
    super.key,
    required this.visible,
    required this.bottomInset,
    required this.onPickPhoto,
    required this.onRecord,
    required this.onPrompt,
    required this.onSave,
  });

  final bool visible;
  final double bottomInset;
  final VoidCallback onPickPhoto;
  final VoidCallback onRecord;
  final VoidCallback onPrompt;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 8),
          child: GlassCard(
            opacity: 0.15,
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                _iconButton(Icons.photo_library_outlined, onPickPhoto),
                const SizedBox(width: 20),
                _iconButton(Icons.mic_none_rounded, onRecord),
                const SizedBox(width: 20),
                _iconButton(Icons.casino_outlined, onPrompt),
                const Spacer(),
                FilledButton.icon(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8FA5BA),
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 24, color: Colors.white.withValues(alpha: 0.9)),
      ),
    );
  }
}
