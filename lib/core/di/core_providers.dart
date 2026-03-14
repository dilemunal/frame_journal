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

