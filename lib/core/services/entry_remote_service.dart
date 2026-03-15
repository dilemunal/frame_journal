import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/api_client.dart';

class EntryRemoteService {
  EntryRemoteService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  /// Backend'deki sayfalı GET /api/v1/entries cevabını alıp Drift'e yazar (mevcut kullanıcı kayıtları silinir, gelen sayfalar eklenir).
  Future<void> syncToLocal(AppDatabase db, int userId) async {
    try {
      await (db.delete(db.appEntries)..where((e) => e.userId.equals(userId))).go();

      int currentPage = 0;
      const pageSize = 50;
      bool hasNext = true;

      while (hasNext) {
        final res = await _api.get(
          '/api/v1/entries',
          queryParameters: {'page': currentPage, 'size': pageSize},
        );
        final data = res.data;
        // ignore: avoid_print
        print('====== SYNC DEBUG: SAYFA $currentPage ======');
        // ignore: avoid_print
        print('Gelen raw data: $data');
        if (data is! Map<String, dynamic>) break;

        final entries = data['entries'];
        if (entries is! List) break;
        // ignore: avoid_print
        print('Okunan Liste Uzunluğu: ${entries.length}');

        for (final raw in entries) {
          if (raw is! Map<String, dynamic>) continue;
          final map = raw;
          final id = map['id'] as int?;
          final title = map['title'] as String?;
          final freeText = map['freeText'] as String? ?? map['free_text'] as String?;
          final mood = map['mood'] as String?;
          final valuesJson = map['valuesJson'] as String? ?? map['values_json'] as String?;
          final locationJson = map['locationJson'] as String? ?? map['location_json'] as String?;
          final weatherJson = map['weatherJson'] as String? ?? map['weather_json'] as String?;
          final templateId = _intFromDynamic(map['templateId'] ?? map['template_id']);
          final createdAt = _dateTimeFromDynamic(map['createdAt'] ?? map['created_at']);
          final unlockAt = _dateTimeFromDynamic(map['unlockAt'] ?? map['unlock_at']);

          // ignore: avoid_print
          print('Parse edilen entry: id=${raw['id']}, createdAt=$createdAt, freeText=$freeText');
          if (createdAt == null) {
            // ignore: avoid_print
            print('UYARI: createdAt null olduğu için bu entry atlandı! Raw: $raw');
            continue;
          }

          await db.into(db.appEntries).insert(
            AppEntriesCompanion.insert(
              id: id != null ? Value(id) : const Value.absent(),
              userId: userId,
              title: title != null ? Value(title) : const Value.absent(),
              freeText: Value(freeText),
              mood: Value(mood),
              valuesJson: valuesJson != null ? Value(valuesJson) : const Value.absent(),
              locationJson: locationJson != null ? Value(locationJson) : const Value.absent(),
              weatherJson: weatherJson != null ? Value(weatherJson) : const Value.absent(),
              templateId: templateId != null ? Value(templateId) : const Value.absent(),
              createdAt: createdAt,
              unlockAt: unlockAt != null ? Value(unlockAt) : const Value.absent(),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }

        hasNext = data['hasMore'] as bool? ?? false;
        currentPage++;
      }
    } catch (e) {
      // ignore: avoid_print
      print('====== SYNC FATAL ERROR: $e ======');
    }
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
    if (v is List && v.length >= 3) {
      try {
        return DateTime(
          v[0] as int,
          v[1] as int,
          v[2] as int,
          v.length > 3 ? v[3] as int : 0,
          v.length > 4 ? v[4] as int : 0,
          v.length > 5 ? v[5] as int : 0,
        );
      } catch (e) {
        // ignore: avoid_print
        print('Date parse error: $e');
        return null;
      }
    }
    return null;
  }

  /// Fetch paginated entries from backend (PagedEntriesResponse: entries, hasMore).
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
