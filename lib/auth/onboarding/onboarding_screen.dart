import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _pages = [
    _OnboardData(
      emoji: '🎓',
      title: 'Learn from\nYour Seniors',
      subtitle: 'Get real guidance from Aditya College alumni who cracked top companies. Not random YouTube advice — actual experiences from your college.',
      gradient: [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
      tag: 'ALUMNI GUIDANCE',
    ),
    _OnboardData(
      emoji: '🚀',
      title: 'Build the Right\nSkill Path',
      subtitle: 'Understand exactly which skills give the best packages from our college. Skill → Package mapping based on real alumni data.',
      gradient: [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
      tag: 'CAREER ROADMAP',
    ),
    _OnboardData(
      emoji: '🏆',
      title: 'Get Placed &\nGrow Continuously',
      subtitle: 'From 1st year to final year, GraduWay evolves with you — placement prep, mentorship, job referrals, and career tracking.',
      gradient: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
      tag: 'LIFELONG GROWTH',
    ),
  ];

  void _completeOnboarding() {
    ref.read(hasSeenOnboardingProvider.notifier).state = true;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < 2)
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => _OnboardingPage(data: _pages[index], index: index),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: AppColors.primary,
                        dotColor: AppColors.border,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _currentPage < 2
                        ? _buildNextButton()
                        : _buildGetStartedButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () => _controller.nextPage(duration: 400.ms, curve: Curves.easeInOut),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Next', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return GestureDetector(
      onTap: _completeOnboarding,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Get Started 🚀', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardData data;
  final int index;
  const _OnboardingPage({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Emoji in gradient circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: data.gradient),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: data.gradient[0].withOpacity(0.35), blurRadius: 40, spreadRadius: 5)],
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 70)),
            ),
          )
              .animate(key: ValueKey(index))
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          // Tag pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: data.gradient),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.tag,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
            ),
          )
              .animate(key: ValueKey('tag_$index'))
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0, delay: 200.ms),

          const SizedBox(height: 20),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          )
              .animate(key: ValueKey('title_$index'))
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .slideX(begin: -0.2, end: 0, delay: 300.ms),

          const SizedBox(height: 20),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          )
              .animate(key: ValueKey('sub_$index'))
              .fadeIn(delay: 450.ms, duration: 500.ms),
          const SizedBox(height: 40), // Extra space for scrolling
        ],
      ),
    );
  }
}

class _OnboardData {
  final String emoji, title, subtitle, tag;
  final List<Color> gradient;
  const _OnboardData({required this.emoji, required this.title, required this.subtitle, required this.gradient, required this.tag});
}
