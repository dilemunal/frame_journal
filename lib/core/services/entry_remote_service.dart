import '../network/api_client.dart';

class EntryRemoteService {
  EntryRemoteService({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

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
