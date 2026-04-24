import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/alumni/chat/mentor_inbox_page.dart';
import 'package:graduway/alumni/notifications/notifications_page.dart';
import 'package:graduway/alumni/profile/profile_page.dart';
import 'package:graduway/alumni/profile/profile_setup_page.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:graduway/alumni/shared/core/widgets/floating_navbar.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/alumni/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Dashboard(),
    const MentorInboxPage(),
    const NotificationsPage(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Setup guard removed to skip the page setup in logins as requested.

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),

              // Verification Warning Banner
              if (auth.status == UserStatus.pending)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.orange.withOpacity(0.95),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          const Icon(Icons.hourglass_empty_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Verification Pending. Some features are restricted.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              auth.syncStatusWithServer();
                              auth.submitForVerification(); // Trigger mock verify for demo/debug
                            },
                            child: Text(
                                kDebugMode ? "BYPASS / REFRESH" : "REFRESH",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideY(begin: -1, end: 0, duration: 600.ms),

              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingNavbar(
                  selectedIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 64, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.textLight)),
          const SizedBox(height: 8),
          const Text("Coming soon as part of the premium experience",
              style: TextStyle(color: AppColors.textLight)),
        ],
      ),
    );
  }
}

