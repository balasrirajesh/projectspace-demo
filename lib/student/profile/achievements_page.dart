import 'package:flutter/material.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Badges & Recognition"),
        backgroundColor: const Color(0xFFFFD54F),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildBadgeCategory("Platform Status", [
            _buildBadgeCard("Top Mentor", "Top 5% active mentors",
                Icons.verified_user_rounded, Colors.blue),
            _buildBadgeCard("Fast Responder", "Avg response < 2hrs",
                Icons.bolt_rounded, Colors.amber),
          ]),
          const SizedBox(height: 32),
          _buildBadgeCategory("Experience", [
            _buildBadgeCard("10+ Sessions", "Completed mentorships",
                Icons.groups_rounded, Colors.green),
            _buildBadgeCard("Topic Expert", "Highly rated in Flutter",
                Icons.psychology_outlined, Colors.purple),
          ]),
        ],
      ),
    );
  }

  Widget _buildBadgeCategory(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildBadgeCard(String name, String desc, IconData icon, Color color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing:
            const Icon(Icons.lock_open_rounded, color: Colors.green, size: 20),
      ),
    );
  }
}
