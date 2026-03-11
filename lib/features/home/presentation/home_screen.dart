import 'dart:ui';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          const _HorizonLine(),
          const _WaterLines(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 40),
                  _TopBar(),
                  SizedBox(height: 10),
                  _WeekRow(),
                  Spacer(),
                  _TodaySection(),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
          const _BottomNavPill(),
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFCDD5DC),
            Color(0xFFC4CDD6),
            Color(0xFFBBCAD4),
            Color(0xFFB8C4C8),
            Color(0xFFBEC4C0),
            Color(0xFFC8C4B4),
            Color(0xFFD0C4A8),
            Color(0xFFCEC0A0),
          ],
        ),
      ),
    );
  }
}

class _HorizonLine extends StatelessWidget {
  const _HorizonLine();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.05),
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFC8BEA8).withOpacity(0.45),
              const Color(0xFFD2C6AC).withOpacity(0.6),
              const Color(0xFFC8BEA8).withOpacity(0.45),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterLines extends StatelessWidget {
  const _WaterLines();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.2),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Stack(
          children: List.generate(6, (index) {
            final top = 0.1 + index * 0.13;
            return Positioned.fill(
              top: top * MediaQuery.of(context).size.height * 0.5,
              child: Align(
                alignment: Alignment.topCenter,
                child: AnimatedOpacity(
                  opacity: 0.35,
                  duration: const Duration(milliseconds: 1500),
                  child: Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.32),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İyi Günler',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w200,
                color: const Color(0xFF201C14).withOpacity(0.8),
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _GlassPill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.brush_rounded, size: 16, color: Color(0xFF4A4330)),
                  SizedBox(width: 8),
                  Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFF4A4330)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const _Avatar(),
          ],
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow();

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 1,
          fontWeight: FontWeight.w300,
          color: const Color(0xFF3C3728).withOpacity(0.35),
        );

    Widget chip(String label, {bool isToday = false}) {
      final style = baseStyle?.copyWith(
        color: isToday
            ? const Color(0xFF28241A).withOpacity(0.68)
            : baseStyle.color,
      );
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Text(label, style: style),
            if (isToday)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF64583C).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          chip('P'),
          chip('S'),
          chip('Ç'),
          chip('P', isToday: true),
          chip('C'),
          chip('C'),
          chip('P'),
        ],
      ),
    );
  }
}

class _TodaySection extends StatelessWidget {
  const _TodaySection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '✦',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF242016).withOpacity(0.55),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Bugün için',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w300,
                color: const Color(0xFF242016).withOpacity(0.55),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _TemplateCard(
                emoji: '🤿',
                labelLines: ['Dalış', 'Günlüğü'],
                variant: _TemplateCardVariant.primary,
              ),
              _TemplateCard(
                emoji: '💧',
                labelLines: ['Su', 'Takibi'],
                variant: _TemplateCardVariant.primary,
              ),
              _TemplateCard(
                emoji: '📖',
                labelLines: ['Serbest', 'Yazı'],
                variant: _TemplateCardVariant.secondary,
              ),
              _TemplateCard(
                emoji: '🎾',
                labelLines: ['Tenis', 'Maçı'],
                variant: _TemplateCardVariant.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _TemplateCardVariant { primary, secondary }

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.emoji,
    required this.labelLines,
    required this.variant,
  });

  final String emoji;
  final List<String> labelLines;
  final _TemplateCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == _TemplateCardVariant.primary;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: _GlassContainer(
        opacity: isPrimary ? 0.2 : 0.15,
        borderOpacity: isPrimary ? 0.5 : 0.38,
        child: SizedBox(
          width: 112,
          height: 96,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  labelLines.join('\n'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF221E14).withOpacity(0.72),
                        height: 1.2,
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

class _BottomNavPill extends StatelessWidget {
  const _BottomNavPill();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFD2CFC3).withOpacity(0.52),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.65),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF373020).withOpacity(0.09),
                    offset: const Offset(0, 2),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Ana',
                    isActive: true,
                  ),
                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Şablonlar',
                  ),
                  _NavItem(
                    icon: Icons.watch_later_outlined,
                    label: 'Anılar',
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Profil',
                  ),
                ],
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
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF241C16).withOpacity(0.75);
    final inactiveColor = const Color(0xFF504834).withOpacity(0.38);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.38) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w300,
                    color: isActive
                        ? const Color(0xFF241C16).withOpacity(0.7)
                        : const Color(0xFF504834).withOpacity(0.35),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            Color(0xFFD4956A),
            Color(0xFFA0B8D0),
            Color(0xFF8EAAC0),
            Color(0xFFC4AA88),
            Color(0xFFD4956A),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      opacity: 0.2,
      borderOpacity: 0.5,
      borderRadius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: child,
    );
  }
}

class _GlassContainer extends StatelessWidget {
  const _GlassContainer({
    required this.child,
    this.opacity = 0.2,
    this.borderOpacity = 0.5,
    this.borderRadius = 20,
    this.padding,
  });

  final Widget child;
  final double opacity;
  final double borderOpacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding ?? EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}


