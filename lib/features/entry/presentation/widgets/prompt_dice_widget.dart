import 'package:flutter/material.dart';

import '../../../../core/data/prompt_questions.dart';
import '../../../../core/theme/app_theme.dart';

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
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.textPrimary.withValues(alpha: 0.25),
              width: 1,
            ),
            color: AppColors.surface.withValues(alpha: 0.9),
          ),
          child: const Center(
            child: Text('🎲', style: TextStyle(fontSize: 18)),
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
