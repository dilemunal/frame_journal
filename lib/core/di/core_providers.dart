import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../auth/token_storage.dart';
import '../database/app_database.dart';
import '../database/seed_templates.dart';
import '../models/atmosphere_data.dart';
import '../network/api_client.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.read(tokenStorageProvider));
});

final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>((
  ref,
) {
  return TokenStorage();
});

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Şablon listesi; ilk okumada seed çalışır, sonra tüm şablonlar döner.
final FutureProvider<List<JournalTemplate>> journalTemplatesProvider =
    FutureProvider<List<JournalTemplate>>((ref) async {
      final db = ref.read(appDatabaseProvider);
      await seedDefaultTemplates(db);
      return db.select(db.journalTemplates).get();
    });

/// Şablon bazlı entry sayısı. templateId -> count. Sadece templateId dolu entry'ler.
final FutureProvider<Map<int, int>> templateUsageCountProvider =
    FutureProvider<Map<int, int>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  final entries = await (db.select(db.appEntries)
        ..where((e) => e.userId.equals(userId)))
      .get();
  final map = <int, int>{};
  for (final e in entries) {
    final id = e.templateId;
    if (id != null) {
      map[id] = (map[id] ?? 0) + 1;
    }
  }
  return map;
});

/// Belirli şablonun alanları (sortOrder'a göre).
final templateFieldsProvider =
    FutureProvider.autoDispose.family<List<TemplateField>, int>((ref, templateId) async {
  final db = ref.read(appDatabaseProvider);
  return (db.select(db.templateFields)
        ..where((f) => f.templateId.equals(templateId))
        ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)]))
      .get();
});

/// Yerel kullanıcı id (giriş yokken veya eski veri ile uyumluluk).
const int kLocalUserId = 1;

/// Giriş yapan kullanıcıya göre yerel veri ayrımı. E-posta ile stabil id (aynı mail = aynı id).
final Provider<int> currentUserIdProvider = Provider<int>((ref) {
  final email = ref.watch(authNotifierProvider).email;
  if (email == null || email.isEmpty) return kLocalUserId;
  final id = email.hashCode.abs();
  return id == 0 ? kLocalUserId : id;
});

const _kLegacyEntriesMigratedKey = 'legacy_entries_migrated';

/// Tek seferlik: user_id = 1 olan tüm girişleri giriş yapan kullanıcıya taşır (test@frame.app vb. eski kayıtlar görünsün).
final FutureProvider<void> legacyEntriesMigrationProvider =
    FutureProvider<void>((ref) async {
  final auth = ref.read(authNotifierProvider);
  if (!auth.isAuthenticated || auth.email == null || auth.email!.isEmpty) {
    return;
  }
  final userId = ref.read(currentUserIdProvider);
  if (userId == kLocalUserId) return;

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_kLegacyEntriesMigratedKey) == true) return;

  final db = ref.read(appDatabaseProvider);
  await (db.update(db.appEntries)..where((e) => e.userId.equals(kLocalUserId)))
      .write(AppEntriesCompanion(userId: Value(userId)));

  await prefs.setBool(_kLegacyEntriesMigratedKey, true);

  ref.invalidate(recentEntriesProvider);
  ref.invalidate(memoryEntriesProvider);
  ref.invalidate(filteredMemoryEntriesProvider);
  ref.invalidate(usedTemplatesProvider);
  ref.invalidate(templateUsageCountProvider);
  ref.invalidate(entryDetailProvider);
  ref.invalidate(last30DaysEntryCountProvider);
  ref.invalidate(last14DaysMoodProvider);
  ref.invalidate(hourDistributionProvider);
  ref.invalidate(thisWeekEntriesProvider);
  ref.invalidate(pastYearsTodayEntriesProvider);
  ref.invalidate(filmRollFramesProvider);
});

/// Son 3 giriş + şablon bilgisi (kart rengi/ikon için).
final FutureProvider<List<(AppEntry, JournalTemplate?)>> recentEntriesProvider =
    FutureProvider<List<(AppEntry, JournalTemplate?)>>((ref) async {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.watch(currentUserIdProvider);
      final entries =
          await (db.select(db.appEntries)
                ..where((e) => e.userId.equals(userId))
                ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
                ..limit(3))
              .get();
      if (entries.isEmpty) return [];
      final templateIds = entries
          .map((e) => e.templateId)
          .whereType<int>()
          .toSet();
      final templates = templateIds.isEmpty
          ? <JournalTemplate>[]
          : await (db.select(
              db.journalTemplates,
            )..where((t) => t.id.isIn(templateIds))).get();
      final templateMap = {for (var t in templates) t.id: t};
      return entries
          .map(
            (e) => (e, e.templateId != null ? templateMap[e.templateId] : null),
          )
          .toList();
    });

/// Hafıza kartı: son 20 giriş + şablon (kart listesi için).
final FutureProvider<List<(AppEntry, JournalTemplate?)>> memoryEntriesProvider =
    FutureProvider<List<(AppEntry, JournalTemplate?)>>((ref) async {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.watch(currentUserIdProvider);
      final entries =
          await (db.select(db.appEntries)
                ..where((e) => e.userId.equals(userId))
                ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
                ..limit(20))
              .get();
      if (entries.isEmpty) return [];
      final templateIds = entries
          .map((e) => e.templateId)
          .whereType<int>()
          .toSet();
      final templates = templateIds.isEmpty
          ? <JournalTemplate>[]
          : await (db.select(
              db.journalTemplates,
            )..where((t) => t.id.isIn(templateIds))).get();
      final templateMap = {for (var t in templates) t.id: t};
      return entries
          .map(
            (e) => (e, e.templateId != null ? templateMap[e.templateId] : null),
          )
          .toList();
    });

/// Filtrelenebilir hafıza: (filterId, limit). templateId null = tümü, -1 = serbest, >0 = şablon.
final filteredMemoryEntriesProvider =
    FutureProvider.family<List<(AppEntry, JournalTemplate?)>, (int?, int)>((ref, params) async {
      final filterId = params.$1;
      final limit = params.$2;
      final db = ref.read(appDatabaseProvider);
      final userId = ref.watch(currentUserIdProvider);
      final cap = limit > 500 ? 500 : limit;
      final entries = await (db.select(db.appEntries)
            ..where((e) => e.userId.equals(userId))
            ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
            ..limit(cap))
          .get();
      List<AppEntry> filtered;
      if (filterId == null) {
        filtered = entries;
      } else if (filterId == -1) {
        filtered = entries.where((e) => e.templateId == null).toList();
      } else {
        filtered = entries.where((e) => e.templateId == filterId).toList();
      }
      if (filtered.length > limit) {
        filtered = filtered.sublist(0, limit);
      }
      if (filtered.isEmpty) return [];
      final templateIds = filtered
          .map((e) => e.templateId)
          .whereType<int>()
          .toSet();
      final templates = templateIds.isEmpty
          ? <JournalTemplate>[]
          : await (db.select(db.journalTemplates)
                ..where((t) => t.id.isIn(templateIds)))
              .get();
      final templateMap = {for (var t in templates) t.id: t};
      return filtered
          .map(
            (e) => (e, e.templateId != null ? templateMap[e.templateId] : null),
          )
          .toList();
    });

/// Entry'si olan şablonlar + Serbest. Chip listesi için. filterId: null = Serbest, >0 = templateId.
class UsedTemplateChip {
  const UsedTemplateChip({required this.filterId, required this.label, this.icon});
  final int? filterId; // -1 = Serbest, 1,2,3 = template id
  final String label;
  final String? icon;
}

final FutureProvider<List<UsedTemplateChip>> usedTemplatesProvider =
    FutureProvider<List<UsedTemplateChip>>((ref) async {
      final db = ref.read(appDatabaseProvider);
      final userId = ref.watch(currentUserIdProvider);
      final entries = await (db.select(db.appEntries)
            ..where((e) => e.userId.equals(userId)))
          .get();
      final hasFree = entries.any((e) => e.templateId == null);
      final templateIds = entries.map((e) => e.templateId).whereType<int>().toSet();
      final chips = <UsedTemplateChip>[];
      if (hasFree) {
        chips.add(const UsedTemplateChip(filterId: -1, label: 'Serbest', icon: null));
      }
      if (templateIds.isNotEmpty) {
        final templates = await (db.select(db.journalTemplates)
              ..where((t) => t.id.isIn(templateIds)))
            .get();
        for (final t in templates) {
          chips.add(UsedTemplateChip(filterId: t.id, label: t.name, icon: t.icon));
        }
        chips.sort((a, b) => (a.label).compareTo(b.label));
      }
      return chips;
    });

/// Varsayılan şablon id (Bugünü kaydet). null = serbest.
final FutureProvider<int?> defaultTemplateIdProvider =
    FutureProvider<int?>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final rows = await (db.select(db.userSettings)..limit(1)).get();
  return rows.isEmpty ? null : rows.single.defaultTemplateId;
});

/// Varsayılan şablon güncelleme.
final Provider<DefaultTemplateNotifier> defaultTemplateNotifierProvider =
    Provider<DefaultTemplateNotifier>((ref) => DefaultTemplateNotifier(ref));

class DefaultTemplateNotifier {
  DefaultTemplateNotifier(this._ref);
  final Ref _ref;

  Future<void> setDefaultTemplateId(int? templateId) async {
    final db = _ref.read(appDatabaseProvider);
    final rows = await (db.select(db.userSettings)..limit(1)).get();
    if (rows.isEmpty) {
      await db.into(db.userSettings).insert(
            UserSettingsCompanion.insert(defaultTemplateId: Value(templateId)),
          );
    } else {
      await (db.update(db.userSettings)
            ..where((r) => r.id.equals(rows.single.id)))
          .write(UserSettingsCompanion(defaultTemplateId: Value(templateId)));
    }
    _ref.invalidate(defaultTemplateIdProvider);
  }
}

/// Tek giriş detayı (id ile). Giriş bulunamazsa veya başka kullanıcıya aitse null döner.
final entryDetailProvider =
    FutureProvider.family<(AppEntry, JournalTemplate?)?, int>((ref, id) async {
  final db = ref.read(appDatabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  final entries = await (db.select(db.appEntries)
        ..where((e) => e.id.equals(id) & e.userId.equals(userId)))
      .get();
  final entry = entries.isEmpty ? null : entries.single;
  if (entry == null) return null;
  JournalTemplate? template;
  if (entry.templateId != null) {
    final list = await (db.select(db.journalTemplates)
          ..where((t) => t.id.equals(entry.templateId!)))
        .get();
    template = list.isEmpty ? null : list.single;
  }
  return (entry, template);
});

/// Konum + hava durumu (entry ekranı AtmosphereStrip için).
final atmosphereProvider =
    FutureProvider.autoDispose<AtmosphereData?>((ref) async {
  final location = await LocationService().getCurrentLocation();
  if (location == null) return null;
  final weather =
      await WeatherService().getWeather(location.lat, location.lng);
  return AtmosphereData(location: location, weather: weather);
});

// --- Ritim istatistikleri (AppEntries + RhythmCompletions) ---

String _dateKey(DateTime d) {
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// Son 30 günün her günü için entry sayısı. Key: "YYYY-MM-DD", value: count.
final FutureProvider<Map<String, int>> last30DaysEntryCountProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: 30));
  final entries = await (db.select(db.appEntries)
        ..where((e) => e.userId.equals(userId))
        ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
        ..limit(500))
      .get();
  final map = <String, int>{};
  for (final e in entries) {
    if (e.createdAt.isBefore(start)) continue;
    final key = _dateKey(e.createdAt);
    map[key] = (map[key] ?? 0) + 1;
  }
  return map;
});

/// Son 14 günün her günü için o günün son entry'sinin mood'u. (tarih, mood emoji); yoksa null.
final FutureProvider<List<(DateTime, String?)>> last14DaysMoodProvider =
    FutureProvider<List<(DateTime, String?)>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: 14));
  final entries = await (db.select(db.appEntries)
        ..where((e) => e.userId.equals(userId))
        ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
        ..limit(300))
      .get();
  final inRange =
      entries.where((e) => !e.createdAt.isBefore(start)).toList();
  final byDay = <String, AppEntry>{};
  for (final e in inRange) {
    final key = _dateKey(e.createdAt);
    if (!byDay.containsKey(key)) byDay[key] = e;
  }
  final result = <(DateTime, String?)>[];
  for (var i = 0; i < 15; i++) {
    final d = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: 14 - i));
    final key = _dateKey(d);
    final entry = byDay[key];
    result.add((d, entry?.mood));
  }
  return result;
});

/// Saat dağılımı: morning 6–12, afternoon 12–18, night 18–6. AppEntries createdAt.hour'a göre.
final FutureProvider<Map<String, int>> hourDistributionProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  final entries = await (db.select(db.appEntries)
        ..where((e) => e.userId.equals(userId)))
      .get();
  int morning = 0, afternoon = 0, night = 0;
  for (final e in entries) {
    final h = e.createdAt.hour;
    if (h >= 6 && h < 12) {
      morning++;
    } else if (h >= 12 && h < 18) {
      afternoon++;
    } else {
      night++;
    }
  }
  return {'morning': morning, 'afternoon': afternoon, 'night': night};
});

/// Bu haftanın her günü (Pazartesi–Pazar) için (entry sayısı, mood). Key: günün 00:00 DateTime.
final FutureProvider<Map<DateTime, (int, String?)>> thisWeekEntriesProvider =
    FutureProvider<Map<DateTime, (int, String?)>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  final now = DateTime.now();
  final weekday = now.weekday;
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: weekday - 1));
  final sunday = monday.add(const Duration(days: 6));
  final end = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
  final entries = await (db.select(db.appEntries)
        ..where((e) => e.userId.equals(userId))
        ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
        ..limit(200))
      .get();
  final inWeek = entries
      .where((e) =>
          !e.createdAt.isBefore(monday) && !e.createdAt.isAfter(end))
      .toList();
  final countByDay = <String, int>{};
  final lastByDay = <String, AppEntry>{};
  for (final e in inWeek) {
    final key = _dateKey(e.createdAt);
    countByDay[key] = (countByDay[key] ?? 0) + 1;
    if (!lastByDay.containsKey(key) ||
        e.createdAt.isAfter(lastByDay[key]!.createdAt)) {
      lastByDay[key] = e;
    }
  }
  final result = <DateTime, (int, String?)>{};
  for (var i = 0; i < 7; i++) {
    final d = monday.add(Duration(days: i));
    final key = _dateKey(d);
    final count = countByDay[key] ?? 0;
    final mood = lastByDay[key]?.mood;
    result[d] = (count, mood);
  }
  return result;
});

/// Geçmişten bugün: bu ay ve gün ile eşleşen geçmiş yıllardaki entry'ler. En fazla 3, yeniden eskiye.
final FutureProvider<List<AppEntry>> pastYearsTodayEntriesProvider =
    FutureProvider<List<AppEntry>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  final now = DateTime.now();
  final month = now.month;
  final day = now.day;
  final thisYear = now.year;
  final entries = await (db.select(db.appEntries)
        ..where((e) => e.userId.equals(userId))
        ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
      .get();
  final list = <AppEntry>[];
  for (final e in entries) {
    if (e.createdAt.month == month &&
        e.createdAt.day == day &&
        e.createdAt.year != thisYear) {
      list.add(e);
      if (list.length >= 3) break;
    }
  }
  return list;
});

/// Film Roll: her gün için tek kare (o günün en son entry'si). Tarihe göre yeniden eskiye.
final FutureProvider<List<(DateTime, AppEntry)>> filmRollFramesProvider =
    FutureProvider<List<(DateTime, AppEntry)>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  final entries = await (db.select(db.appEntries)
        ..where((e) => e.userId.equals(userId))
        ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
      .get();
  final byDay = <String, AppEntry>{};
  for (final e in entries) {
    final key = _dateKey(e.createdAt);
    if (!byDay.containsKey(key)) byDay[key] = e;
  }
  final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
  return days
      .map((k) {
        final e = byDay[k]!;
        final dt = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
        return (dt, e);
      })
      .toList();
});
