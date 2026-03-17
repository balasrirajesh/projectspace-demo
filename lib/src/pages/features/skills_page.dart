import 'package:flutter/material.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Skills & Expertise"),
        backgroundColor: const Color(0xFF81C784),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSkillSection("Primary Skills", ["Flutter", "Dart", "Firebase", "Android"]),
            const SizedBox(height: 20),
            _buildSkillSection("Secondary Skills", ["REST APIs", "System Design", "UI/UX", "Node.js"]),
            const SizedBox(height: 20),
            _buildSkillSection("Tools", ["Git", "Docker", "Figma", "VS Code", "Jenkins"]),
            const SizedBox(height: 20),
            _buildSkillSection("Certifications", ["Google Certified Developer", "Cloud Solutions Architect"]),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillSection(String title, List<String> skills) {
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: skills.map((skill) => Chip(
              label: Text(skill),
              backgroundColor: const Color(0xFFE8F5E9),
              labelStyle: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
