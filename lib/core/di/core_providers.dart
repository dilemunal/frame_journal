import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/token_storage.dart';
import '../network/api_client.dart';

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final Provider<TokenStorage> tokenStorageProvider =
    Provider<TokenStorage>((ref) {
  return TokenStorage();
});

