import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/auth_provider.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Mock categorization for demo purposes
        final skills = auth.skills.isEmpty
            ? ["Flutter", "Dart", "Firebase", "System Design"]
            : auth.skills;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text("Expertise & Skills"),
            backgroundColor: const Color(0xFF81C784),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMentorshipStats(),
                const SizedBox(height: 32),
                const Text("Core Competencies",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSkillCategory(
                    "Technical Skills",
                    skills,
                    Icons.code_rounded,
                    const Color(0xFFE8F5E9),
                    const Color(0xFF2E7D32)),
                const SizedBox(height: 16),
                _buildSkillCategory(
                    "Soft Skills",
                    ["Mentorship", "Public Speaking", "Team Lead"],
                    Icons.people_outline_rounded,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF1976D2)),
                const SizedBox(height: 24),
                _buildInfoCard(
                    "These topics help students find you for specific mentorship needs."),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMentorshipStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem("5.0", "Rating", Icons.star_rounded, Colors.amber),
            const VerticalDivider(width: 1),
            _buildStatItem(
                "12", "Endorsed", Icons.verified_outlined, Colors.blue),
            const VerticalDivider(width: 1),
            _buildStatItem(
                "5+", "Years", Icons.history_edu_rounded, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(val,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildSkillCategory(String title, List<String> skills, IconData icon,
      Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(skill,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          const SizedBox(width: 4),
                          Icon(Icons.check_circle,
                              size: 12, color: textColor.withOpacity(0.5)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
