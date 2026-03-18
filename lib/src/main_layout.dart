import 'package:flutter/material.dart';
import 'package:alumini_screen/src/pages/nav_tabs/dashboard_page.dart';
import 'package:alumini_screen/src/pages/nav_tabs/profile_page.dart';
import 'package:alumini_screen/src/pages/nav_tabs/mentor_inbox_page.dart';
import 'package:alumini_screen/src/pages/nav_tabs/placeholder_page.dart';
import 'package:alumini_screen/src/widgets/floating_navbar.dart';

/// The main layout of the application after the user logs in.
/// 
/// This widget manages the bottom navigation tabs and switches between
/// the different feature pages (Dashboard, Chat, Alerts, Profile).
/// It uses a [Stack] with [IndexedStack] and a custom [FloatingNavbar].
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  /// The index of the currently active navigation tab.
  int _selectedIndex = 0;

  /// The list of top-level pages corresponding to the navigation tabs.
  final List<Widget> _pages = const [
    Dashboard(), // Index 0
    MentorInboxPage(), // Index 1 (Chat)
    PlaceholderScreen(title: "Alerts", icon: Icons.notifications_none), // Index 2 (Alerts)
    ProfileScreen(), // Index 3 (Profile)
  ];

  /// Updates the selected index when a navigation item is tapped.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBody: true, // Allows content to flow behind the glass navbar to enhance the blur effect.
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
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
  }
}


