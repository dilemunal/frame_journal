import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../core/data/prompt_questions.dart';

/// Sağ alt köşede 🎲 butonu; basınca yeni soru alır, soru seçilince callback.
class PromptDiceButton extends StatelessWidget {
  const PromptDiceButton({
    super.key,
    required this.onPromptSelected,
  });

  final ValueChanged<String?> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final q = await _getNextPrompt();
          onPromptSelected(q);
        },
        customBorder: const CircleBorder(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 0.5,
                ),
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: const Center(
                child: Text('🎲', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _getNextPrompt() async {
    try {
      return await PromptQuestions.next();
    } catch (_) {
      return null;
    }
  }
}
