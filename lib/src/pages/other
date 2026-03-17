import 'package:flutter/material.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Achievements"),
        backgroundColor: const Color(0xFFFFD54F),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAchievementCard(
            "Google Developer Expert",
            "Flutter & Dart",
            "2024",
            Icons.verified_user_outlined,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildAchievementCard(
            "National Hackathon Winner",
            "Smart India Hackathon",
            "2023",
            Icons.emoji_events_outlined,
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildAchievementCard(
            "Speaker",
            "Flutter India Conference",
            "2023",
            Icons.record_voice_over_outlined,
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildAchievementCard(
            "Open Source Contributor",
            "GitHub • Flutter Framework",
            "Active",
            Icons.code_outlined,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String subtitle, String year, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(year, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }
}
