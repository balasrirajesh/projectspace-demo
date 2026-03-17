import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Alumni Guidance"),
        backgroundColor: const Color(0xFF90A4AE),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNoteCard(
            "Resume Preparation Tips",
            "Keep your resume within one page. Highlight your projects and specific contributions clearly. Use action verbs and quantify results where possible.",
            Icons.description_outlined,
            Colors.blueGrey,
          ),
          const SizedBox(height: 16),
          _buildNoteCard(
            "Interview Advice",
            "Focus on problem-solving and communication skills. Don't just give the answer; explain your thought process. Practice foundational DSA and system design.",
            Icons.forum_outlined,
            Colors.indigo,
          ),
          const SizedBox(height: 16),
          _buildNoteCard(
            "Learning Resources",
            "Focus on official documentation. For Flutter, visit flutter.dev. Follow top engineering blogs like Uber, Airbnb, and Google for system design insights.",
            Icons.library_books_outlined,
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
          ),
        ],
      ),
    );
  }
}
