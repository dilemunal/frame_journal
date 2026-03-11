import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/di/providers.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Frame Journal',
      theme: _buildTheme(),
      routerConfig: router,
    );
  }

  ThemeData _buildTheme() {
    const background = Color(0xFFA8AFA2);
    const surface = Color(0xFFF5F0E4);
    const accent = Color(0xFF8FA5BA);
    const textMain = Color(0xFF242018);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        surface: surface,
      ),
    );

    final figtreeTextTheme = GoogleFonts.figtreeTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: figtreeTextTheme,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textMain,
      ),
    );
  }
}

