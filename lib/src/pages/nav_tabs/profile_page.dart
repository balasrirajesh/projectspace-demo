import 'package:flutter/material.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/professional_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/skills_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/activities_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/notes_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/contact_page.dart';
import 'package:alumini_screen/src/pages/features/Common/detail_page.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String techField;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.techField,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompactHeader(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGridDashboard(context),
                    const SizedBox(height: 100), // Space for floating navbar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topPadding + 20, left: 24, right: 24, bottom: 70),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA294F9), Color(0xFF7B66FF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildHeaderAction(context, Icons.edit_outlined, "Edit Profile"),
                  const SizedBox(width: 12),
                  _buildHeaderAction(context, Icons.notifications_outlined, "Notifications"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 64),
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 35),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$techField • Google",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.school_outlined, color: Colors.white.withOpacity(0.7), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Batch 2022 • CS",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(title: title, icon: icon, themeColor: const Color(0xFF7B66FF)))),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildGridDashboard(BuildContext context) {
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
          "Professional",
          "Company, Role",
          Icons.business_center_outlined,
          const Color(0xFF64B5F6),
          const ProfessionalPage(),
        ),
        _buildDashboardCard(
          context,
          "Skills",
          "Tech Stack",
          Icons.psychology_outlined,
          const Color(0xFF81C784),
          const SkillsPage(),
        ),
        _buildDashboardCard(
          context,
          "Achievements",
          "Awards, Certs",
          Icons.emoji_events_outlined,
          const Color(0xFFFFD54F),
          const DetailPage(title: "Achievements", icon: Icons.emoji_events_outlined, themeColor: Color(0xFFFFD54F)), // Use DetailPage as fallback
        ),
        _buildDashboardCard(
          context,
          "Activities",
          "Events, Timeline",
          Icons.event_note_outlined,
          const Color(0xFF4DB6AC),
          const ActivitiesPage(),
        ),
        _buildDashboardCard(
          context,
          "Notes",
          "Personal Info",
          Icons.description_outlined,
          const Color(0xFF90A4AE),
          const NotesPage(),
        ),
        _buildDashboardCard(
          context,
          "Contact",
          "Email, Socials",
          Icons.alternate_email_outlined,
          const Color(0xFFF06292),
          const ContactPage(),
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
