import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  return appRouter(ref);
});

