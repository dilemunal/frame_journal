import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';

/// Günlük ritim slot anahtarları.
const List<String> kRhythmSlotKeys = ['morning', 'noon', 'evening'];

/// Slot görünen adları.
const Map<String, String> kRhythmSlotLabels = {
  'morning': 'Sabah',
  'noon': 'Öğlen',
  'evening': 'Akşam',
};

String _todayString() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// Bugün tamamlanan ritim slot'ları (DB'den okunur/yazılır).
final AsyncNotifierProvider<RhythmCompletionsNotifier, Set<String>>
    rhythmCompletionsProvider =
    AsyncNotifierProvider<RhythmCompletionsNotifier, Set<String>>(
  RhythmCompletionsNotifier.new,
);

class RhythmCompletionsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final db = ref.read(appDatabaseProvider);
    final today = _todayString();
    final rows = await (db.select(db.rhythmCompletions)
          ..where((r) => r.localDate.equals(today)))
        .get();
    return rows.map((r) => r.slotKey).toSet();
  }

  Future<void> toggle(String slotKey) async {
    if (!kRhythmSlotKeys.contains(slotKey)) return;
    final db = ref.read(appDatabaseProvider);
    final today = _todayString();
    final current = state.valueOrNull ?? {};

    if (current.contains(slotKey)) {
      await (db.delete(db.rhythmCompletions)
            ..where((r) =>
                r.localDate.equals(today) & r.slotKey.equals(slotKey)))
          .go();
      state = AsyncValue.data(current.difference({slotKey}));
    } else {
      await db.into(db.rhythmCompletions).insert(
            RhythmCompletionsCompanion.insert(
              localDate: today,
              slotKey: slotKey,
              completedAt: DateTime.now(),
            ),
          );
      state = AsyncValue.data(current.union({slotKey}));
    }
  }
}
