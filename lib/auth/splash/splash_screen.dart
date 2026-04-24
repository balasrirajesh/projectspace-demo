import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      
      final hasSeenOnboarding = ref.read(hasSeenOnboardingProvider);
      if (hasSeenOnboarding) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            // Animated background orbs
            Positioned(
              top: -80,
              right: -80,
              child: _buildOrb(200, AppColors.primary.withOpacity(0.3))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 0.8, end: 1.2, duration: 3.seconds)
                  .blur(begin: const Offset(0, 0), end: const Offset(20, 20)),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: _buildOrb(250, AppColors.secondary.withOpacity(0.2))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 0.9, end: 1.1, duration: 4.seconds)
                  .blur(begin: const Offset(0, 0), end: const Offset(15, 15)),
            ),
            Positioned(
              bottom: 200,
              right: 30,
              child: _buildOrb(100, AppColors.accent.withOpacity(0.2))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 0.7, end: 1.3, duration: 2.5.seconds),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 56),
                  )
                      .animate()
                      .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // App name
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: const Text(
                      'GraduWay',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms, curve: Curves.easeOut),

                  const SizedBox(height: 8),

                  Text(
                    'Aditya Engineering College',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 500.ms),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Alumni • Students • Growth',
                      style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 600.ms),
                ],
              ),
            ),

            // Bottom tagline
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Shimmer loading bar
                  Container(
                    width: 120,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 1.5.seconds, color: AppColors.primaryLight.withOpacity(0.6)),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting generations.\nBuilding futures.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.6,
                      letterSpacing: 0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1.2.seconds, duration: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
