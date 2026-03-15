import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isHome = navigationShell.currentIndex == 0;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          isHome ? 'assets/images/sea.jpg' : 'assets/images/background.webp',
          fit: BoxFit.cover,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          color: AppColors.overlayForHour(hour),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: navigationShell,
          bottomNavigationBar: _GlassBottomNav(
            index: navigationShell.currentIndex,
            onTap: (i) => navigationShell.goBranch(
              i,
              initialLocation: i == navigationShell.currentIndex,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.index,
    required this.onTap,
  });

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassFill13,
              border: Border(
                top: BorderSide(color: AppColors.glassBorder),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 66,
                child: Row(
                  children: [
                    _NavItem(
                      label: 'Ana Sayfa',
                      icon: Icons.home_rounded,
                      selected: index == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      label: 'Ritim',
                      icon: Icons.schedule_rounded,
                      selected: index == 1,
                      onTap: () => onTap(1),
                    ),
                    _NavItem(
                      label: 'Hafıza',
                      icon: Icons.auto_stories_rounded,
                      selected: index == 2,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      label: 'Film',
                      icon: Icons.movie_filter_rounded,
                      selected: index == 3,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = AppColors.textOnGlassPrimary;
    final inactive = Colors.white.withValues(alpha: 0.45);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: selected ? 1 : 0.85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? active : inactive, size: 23),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? active : inactive,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? Colors.white
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
