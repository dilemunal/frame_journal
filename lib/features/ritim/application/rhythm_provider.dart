import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/di/core_providers.dart';

/// Günlük ritim slot anahtarları. 06–12 morning, 12–18 noon, 18–06 evening.
const List<String> kRhythmSlotKeys = ['morning', 'noon', 'evening'];

/// Slot görünen adları.
const Map<String, String> kRhythmSlotLabels = {
  'morning': 'Sabah',
  'noon': 'Öğleden sonra',
  'evening': 'Gece',
};

String _todayString() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// Entry'nin createdAt saatine göre slot: 06:00–11:59 → morning, 12:00–17:59 → noon, 18:00–05:59 → evening.
String rhythmSlotFromDateTime(DateTime dateTime) {
  final h = dateTime.hour;
  if (h >= 6 && h < 12) return 'morning';
  if (h >= 12 && h < 18) return 'noon';
  return 'evening';
}

/// Bugün tamamlanan ritim slot'ları: slotKey → completedAt (entry kaydedilince otomatik yazılır).
final AsyncNotifierProvider<RhythmCompletionsNotifier, Map<String, DateTime>>
    rhythmCompletionsProvider =
    AsyncNotifierProvider<RhythmCompletionsNotifier, Map<String, DateTime>>(
  RhythmCompletionsNotifier.new,
);

class RhythmCompletionsNotifier extends AsyncNotifier<Map<String, DateTime>> {
  @override
  Future<Map<String, DateTime>> build() async {
    final db = ref.read(appDatabaseProvider);
    final today = _todayString();
    final rows = await (db.select(db.rhythmCompletions)
          ..where((r) => r.localDate.equals(today)))
        .get();
    return {for (final r in rows) r.slotKey: r.completedAt};
  }

  /// Entry kaydedildikten sonra çağrılır; ilgili slotu bu zamanla işaretler.
  Future<void> markFromEntryTime(DateTime completedAt) async {
    final slotKey = rhythmSlotFromDateTime(completedAt);
    if (!kRhythmSlotKeys.contains(slotKey)) return;
    final db = ref.read(appDatabaseProvider);
    final today = _todayString();
    await (db.delete(db.rhythmCompletions)
          ..where((r) =>
              r.localDate.equals(today) & r.slotKey.equals(slotKey)))
        .go();
    await db.into(db.rhythmCompletions).insert(
          RhythmCompletionsCompanion.insert(
            localDate: today,
            slotKey: slotKey,
            completedAt: completedAt,
          ),
        );
    ref.invalidateSelf();
  }
}
