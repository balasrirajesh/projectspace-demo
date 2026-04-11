import 'package:flutter/material.dart';
import 'package:alumini_screen/src/features/profile/professional_page.dart';
import 'package:alumini_screen/src/features/profile/skills_page.dart';
import 'package:alumini_screen/src/features/profile/achievements_page.dart';
import 'package:alumini_screen/src/features/profile/scheduler_page.dart';
import 'package:alumini_screen/src/features/mentorship/sessions_page.dart';
import 'package:alumini_screen/src/features/mentorship/mentees_page.dart';
import 'package:alumini_screen/src/features/mentorship/alumni_requests_page.dart';

class ProfileDashboardGrid extends StatelessWidget {
  const ProfileDashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildDashboardCard(
          context,
          "Background",
          "Career & History",
          Icons.workspace_premium_outlined,
          const Color(0xFF64B5F6),
          const ProfessionalPage(),
        ),
        _buildDashboardCard(
          context,
          "Expertise",
          "Mentoring Topics",
          Icons.psychology_outlined,
          const Color(0xFF81C784),
          const SkillsPage(),
        ),
        _buildDashboardCard(
          context,
          "Mentorship",
          "Manage Requests",
          Icons.pending_actions_outlined,
          const Color(0xFFFFB74D),
          const AlumniRequestsPage(),
        ),
        _buildDashboardCard(
          context,
          "Webinars",
          "Host Live Sessions",
          Icons.video_camera_front_outlined,
          const Color(0xFFBA68C8),
          const SessionsPage(),
        ),
        _buildDashboardCard(
          context,
          "Badges",
          "Mentor Recognition",
          Icons.emoji_events_outlined,
          const Color(0xFFFFD54F),
          const AchievementsPage(),
        ),
        _buildDashboardCard(
          context,
          "Office Hours",
          "Availability",
          Icons.calendar_month_outlined,
          const Color(0xFFF06292),
          const SchedulerPage(),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget targetPage) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
