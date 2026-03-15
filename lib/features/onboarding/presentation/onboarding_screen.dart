import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/legal/privacy_notice.dart';


const _kOnboardingDoneKey = 'onboarding_done';

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingDoneKey) ?? false;
});

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDoneKey, true);
    ref.invalidate(onboardingCompleteProvider);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/background.webp',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withValues(alpha: 0.25)),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => _completeOnboarding(),
                      child: Text(
                        'Atla',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      children: [
                        _OnboardingPage(
                          emoji: '📔',
                          title: 'Frame Journal',
                          subtitle: 'Her anın bir çerçevesi var.',
                        ),
                        _OnboardingPage(
                          emoji: '🎨',
                          title: 'Kendi şablonunu oluştur',
                          subtitle: 'Dalış, tenis, kitap — ne takip etmek istersen.',
                        ),
                        _OnboardingPage(
                          emoji: '✨',
                          title: 'Başla',
                          subtitle: null,
                          showButton: true,
                          onButtonTap: _completeOnboarding,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                          ),
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Devam ederek ',
                          ),
                          TextSpan(
                            text: 'Gizlilik Politikamızı',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(Uri.parse(privacyPolicyUrl)),
                          ),
                          const TextSpan(text: ' ve '),
                          TextSpan(
                            text: 'Kullanım Koşullarımızı',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(Uri.parse(termsUrl)),
                          ),
                          const TextSpan(text: ' kabul etmiş olursunuz.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    this.subtitle,
    this.showButton = false,
    this.onButtonTap,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final bool showButton;
  final VoidCallback? onButtonTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 72))
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w300,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 350.ms)
              .slideY(begin: 0.08, end: 0, delay: 150.ms, duration: 350.ms),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            )
                .animate()
                .fadeIn(delay: 250.ms, duration: 350.ms)
                .slideY(begin: 0.06, end: 0, delay: 250.ms, duration: 350.ms),
          ],
          if (showButton && onButtonTap != null) ...[
            const SizedBox(height: 40),
            FilledButton(
              onPressed: onButtonTap,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.95),
                foregroundColor: const Color(0xFF2A2A2A),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Başla'),
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 350.ms)
                .slideY(begin: 0.06, end: 0, delay: 350.ms, duration: 350.ms),
          ],
        ],
      ),
    );
  }
}
