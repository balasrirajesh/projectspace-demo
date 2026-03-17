import 'package:flutter/material.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/professional_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/skills_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/activities_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/notes_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/contact_page.dart';
import 'package:alumini_screen/src/pages/features/Mentorship/alumni_requests_page.dart';
import 'package:alumini_screen/src/pages/features/Common/detail_page.dart';
import 'package:alumini_screen/src/services/mentorship_service.dart';
import 'package:alumini_screen/src/models/mentorship_model.dart';

import 'package:alumini_screen/src/pages/features/Chat/chat_detail_page.dart';

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
                      "Mentor Dashboard",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMentoringBio(),
                    const SizedBox(height: 24),
                    _buildQuickActionButtons(context),
                    const SizedBox(height: 24),
                    _buildGridDashboard(context),
                    const SizedBox(height: 24),
                    _buildActiveMenteesSection(context),
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
                      "$techField • Senior Mentor",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: Colors.white.withOpacity(0.7), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Google • 5+ YOE",
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
          "Experience",
          "Expertise & History",
          Icons.workspace_premium_outlined,
          const Color(0xFF64B5F6),
          const ProfessionalPage(),
        ),
        _buildDashboardCard(
          context,
          "Skillset",
          "Mentoring Topics",
          Icons.psychology_outlined,
          const Color(0xFF81C784),
          const SkillsPage(),
        ),
        _buildDashboardCard(
          context,
          "Requests",
          "Student Queries",
          Icons.pending_actions_outlined,
          const Color(0xFFFFB74D),
          const AlumniRequestsPage(),
        ),
        _buildDashboardCard(
          context,
          "Sessions",
          "Host Webinars",
          Icons.video_camera_front_outlined,
          const Color(0xFFBA68C8),
          const PlaceholderScreen(title: "Sessions", icon: Icons.video_camera_front_outlined),
        ),
        _buildDashboardCard(
          context,
          "Awards",
          "Recognition",
          Icons.emoji_events_outlined,
          const Color(0xFFFFD54F),
          const DetailPage(title: "Mentor Awards", icon: Icons.emoji_events_outlined, themeColor: Color(0xFFFFD54F)),
        ),
        _buildDashboardCard(
          context,
          "Contact",
          "Office Hours",
          Icons.alternate_email_outlined,
          const Color(0xFFF06292),
          const ContactPage(),
        ),
      ],
    );
  }

  Widget _buildMentoringBio() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                "Mentoring Philosophy",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "I believe in building a strong foundation in core engineering principles. Happy to guide students on System Design, Flutter Architecture, and Career Growth.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, {bool isOutlined = false}) {
    return ElevatedButton.icon(
      onPressed: () {
        if (label == "Start Session") {
          _showStartSessionSheet(context);
        } else if (label == "Manage Mentees") {
          // Navigation logic for Manage Mentees (e.g., navigating to Inbox)
          // For now, since it's a tab, we can't easily switch without 
          // state management, so we'll show a message or use Navigator
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MentorInboxPage()));
        }
      },
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.white : color,
        foregroundColor: isOutlined ? const Color(0xFF7B66FF) : Colors.white,
        elevation: isOutlined ? 0 : 2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isOutlined ? const BorderSide(color: Color(0xFF7B66FF)) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildActiveMenteesSection(BuildContext context) {
    final MentorshipService service = MentorshipService();
    final activeMentees = service.getRequests().where((r) => r.status == MentorshipStatus.accepted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Active Mentees",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("See All"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (activeMentees.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text("Provide guidance to start seeing mentees here.", style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...activeMentees.take(2).map((mentee) => _buildMenteeCard(context, mentee)),
      ],
    );
  }

  Widget _buildMenteeCard(BuildContext context, MentorshipRequest mentee) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailPage(mentorship: mentee),
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: Text(mentee.studentName[0], style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mentee.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(mentee.topics.first, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  void _showStartSessionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Start New Session",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Host a webinar or a quick Q&A session.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSessionOption(Icons.video_camera_front_outlined, "Video Webinar", "Host a session for up to 50 students."),
            const SizedBox(height: 12),
            _buildSessionOption(Icons.forum_outlined, "Group Q&A", "A quick text-based interaction."),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B66FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Go Live", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionOption(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Radio(value: true, groupValue: true, onChanged: (_) {}),
        ],
      ),
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
