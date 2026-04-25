import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/theme/app_colors.dart';

class AlumniShell extends ConsumerWidget {
  final Widget child;
  const AlumniShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(alumniNavIndexProvider);

    final tabs = [
      _NavTab(icon: Icons.grid_view_rounded, label: 'Dashboard', path: '/alumni-home'),
      _NavTab(icon: Icons.chat_bubble_outline_rounded, label: 'Chat', path: '/alumni-chat'),
      _NavTab(icon: Icons.notifications_none_rounded, label: 'Requests', path: '/alumni-requests'),
      _NavTab(icon: Icons.person_outline_rounded, label: 'Profile', path: '/alumni-profile'),
    ];

    return Scaffold(
      extendBody: true, // Required for floating nav bar
      body: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: child,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.alumni.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (i) {
                final isSelected = currentIndex == i;
                return GestureDetector(
                  onTap: () {
                    ref.read(alumniNavIndexProvider.notifier).state = i;
                    context.go(tabs[i].path);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.alumni.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabs[i].icon,
                          size: 24,
                          color: isSelected ? AppColors.alumni : Colors.blueGrey.shade300,
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.alumni,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label, path;
  const _NavTab({required this.icon, required this.label, required this.path});
}
