import 'package:graduway/theme/app_colors.dart';
import 'package:graduway/student/shared/services/classroom_service.dart';
import 'package:graduway/alumni/chat/mentor_inbox_page.dart';
import 'package:graduway/student/dashboard/student_dashboard.dart';
import 'package:graduway/alumni/notifications/notifications_page.dart';
import 'package:graduway/profile/profile_screen.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:graduway/alumni/shared/core/widgets/floating_navbar.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/student/mentorship/sessions_page.dart';
import 'package:graduway/student/profile/mentorship_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class StudentMainLayout extends StatefulWidget {
  const StudentMainLayout({super.key});

  @override
  State<StudentMainLayout> createState() => _StudentMainLayoutState();
}

class _StudentMainLayoutState extends State<StudentMainLayout> {
  int _selectedIndex = 0;
  final ClassroomService _classroomService = ClassroomService();

  @override
  void initState() {
    super.initState();
    _setupAnnouncementListener();
  }

  void _setupAnnouncementListener() {
    _classroomService.onAnnouncementReceived = (data) {
      if (mounted) {
        _showAnnouncementDialog(data);
      }
    };
  }

  void _showAnnouncementDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: Colors.indigo),
            SizedBox(width: 12),
            Text("Faculty Update"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['title'] ?? 'Urgent Broadcast',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(data['message'] ?? ''),
            const SizedBox(height: 20),
            Text(
                "Sent: ${data['timestamp']?.toString().substring(11, 16) ?? 'Just now'}",
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Acknowledged")),
        ],
      ),
    );
  }

  final List<Widget> _pages = [
    const StudentDashboard(),
    const SessionsPage(),
    const MentorshipPage(),
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
        // Guard removed: Skipping the page setup in logins per user requirement.

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ), // Removed .animate() chain which was causing blank screen on init

              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingNavbar(
                  selectedIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
              ).animate().slideY(
                  begin: 1,
                  end: 0,
                  duration: 800.ms,
                  curve: Curves.easeOutCubic),
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
          const Text("Coming soon for the premium student experience",
              style: TextStyle(color: AppColors.textLight)),
        ],
      ),
    );
  }
}

