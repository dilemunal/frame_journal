import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Belirli şablonun alanları (sortOrder'a göre).
final templateFieldsProvider =
    FutureProvider.autoDispose.family<List<TemplateField>, int>((ref, templateId) async {
  final db = ref.read(appDatabaseProvider);
  return (db.select(db.templateFields)
        ..where((f) => f.templateId.equals(templateId))
        ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)]))
      .get();
});

/// Yerel kullanıcı id (auth backend'den gelene kadar sabit).
const int kLocalUserId = 1;

/// Son 3 giriş + şablon bilgisi (kart rengi/ikon için).
final FutureProvider<List<(AppEntry, JournalTemplate?)>> recentEntriesProvider =
    FutureProvider<List<(AppEntry, JournalTemplate?)>>((ref) async {
      final db = ref.read(appDatabaseProvider);
      final entries =
          await (db.select(db.appEntries)
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
      final entries =
          await (db.select(db.appEntries)
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

/// Tek giriş detayı (id ile). Giriş bulunamazsa null döner.
final entryDetailProvider =
    FutureProvider.family<(AppEntry, JournalTemplate?)?, int>((ref, id) async {
  final db = ref.read(appDatabaseProvider);
  final entries = await (db.select(db.appEntries)..where((e) => e.id.equals(id)))
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
