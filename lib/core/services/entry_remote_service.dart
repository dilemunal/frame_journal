import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/api_client.dart';

class EntryRemoteService {
  EntryRemoteService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  /// Backend'deki GET /api/v1/entries/sync cevabını alıp Drift'e yazar (mevcut kullanıcı kayıtları silinir, gelen liste eklenir).
  Future<void> syncToLocal(AppDatabase db, int userId) async {
    try {
      final res = await _api.get('/api/v1/entries/sync');
      final data = res.data;
      if (data is! List) return;
      final list = data;

      await (db.delete(db.appEntries)..where((e) => e.userId.equals(userId))).go();

      for (final raw in list) {
        if (raw is! Map<String, dynamic>) continue;
        final map = raw;
        final freeText = map['freeText'] as String? ?? map['free_text'] as String?;
        final mood = map['mood'] as String?;
        final valuesJson = map['valuesJson'] as String? ?? map['values_json'] as String?;
        final locationJson = map['locationJson'] as String? ?? map['location_json'] as String?;
        final weatherJson = map['weatherJson'] as String? ?? map['weather_json'] as String?;
        final templateId = _intFromDynamic(map['templateId'] ?? map['template_id']);
        final createdAt = _dateTimeFromDynamic(map['createdAt'] ?? map['created_at']);
        final unlockAt = _dateTimeFromDynamic(map['unlockAt'] ?? map['unlock_at']);

        if (createdAt == null) continue;

        await db.into(db.appEntries).insert(
          AppEntriesCompanion.insert(
            userId: userId,
            freeText: Value(freeText),
            mood: Value(mood),
            valuesJson: valuesJson != null ? Value(valuesJson) : const Value.absent(),
            locationJson: locationJson != null ? Value(locationJson) : const Value.absent(),
            weatherJson: weatherJson != null ? Value(weatherJson) : const Value.absent(),
            templateId: templateId != null ? Value(templateId) : const Value.absent(),
            createdAt: createdAt,
            unlockAt: unlockAt != null ? Value(unlockAt) : const Value.absent(),
          ),
        );
      }
    } catch (_) {}
  }

  static int? _intFromDynamic(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _dateTimeFromDynamic(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  /// Fetch paginated entries from backend.
  Future<({List<Map<String, dynamic>> entries, bool hasMore})> fetchEntries({
    int page = 0,
    int size = 20,
  }) async {
    final res = await _api.get(
      '/api/v1/entries',
      queryParameters: {'page': page, 'size': size},
    );
    final data = res.data as Map<String, dynamic>;
    return (
      entries: (data['entries'] as List).cast<Map<String, dynamic>>(),
      hasMore: data['hasMore'] as bool,
    );
  }

  /// Push a new entry to backend (fire-and-forget, don't block local save).
  Future<void> pushEntry(Map<String, dynamic> payload) async {
    try {
      await _api.post('/api/v1/entries', data: payload);
    } catch (_) {} // offline-first: silently ignore
  }
}
