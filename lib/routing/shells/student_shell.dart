import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graduway/providers/app_providers.dart';
import 'package:graduway/theme/app_colors.dart';

class StudentShell extends ConsumerWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(studentNavIndexProvider);

    final tabs = [
      _NavTab(icon: Icons.grid_view_rounded, label: 'Dashboard', path: '/home'),
      _NavTab(icon: Icons.chat_bubble_outline_rounded, label: 'Q&A', path: '/qa'),
      _NavTab(icon: Icons.notifications_none_rounded, label: 'Mentors', path: '/mentorship'),
      _NavTab(icon: Icons.person_outline_rounded, label: 'Profile', path: '/profile'),
    ];

    return Scaffold(
      extendBody: true, // Required for floating nav bar
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
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
                color: AppColors.primary.withOpacity(0.1),
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
                    ref.read(studentNavIndexProvider.notifier).state = i;
                    context.go(tabs[i].path);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tabs[i].icon,
                          size: 24,
                          color: isSelected ? AppColors.primary : Colors.blueGrey.shade300,
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
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
