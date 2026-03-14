import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_storage.dart';
import '../database/app_database.dart';
import '../database/seed_templates.dart';
import '../network/api_client.dart';

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.read(tokenStorageProvider));
});

final Provider<TokenStorage> tokenStorageProvider =
    Provider<TokenStorage>((ref) {
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

/// Yerel kullanıcı id (auth backend'den gelene kadar sabit).
const int kLocalUserId = 1;

/// Son 3 giriş + şablon bilgisi (kart rengi/ikon için).
final FutureProvider<List<(AppEntry, JournalTemplate?)>> recentEntriesProvider =
    FutureProvider<List<(AppEntry, JournalTemplate?)>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  final entries = await (db.select(db.appEntries)
        ..orderBy([(e) => OrderingTerm.desc(e.createdAt)])
        ..limit(3))
      .get();
  if (entries.isEmpty) return [];
  final templateIds = entries.map((e) => e.templateId).whereType<int>().toSet();
  final templates = templateIds.isEmpty
      ? <JournalTemplate>[]
      : await (db.select(db.journalTemplates)
            ..where((t) => t.id.isIn(templateIds)))
          .get();
  final templateMap = {for (var t in templates) t.id: t};
  return entries.map((e) => (e, e.templateId != null ? templateMap[e.templateId] : null)).toList();
});

