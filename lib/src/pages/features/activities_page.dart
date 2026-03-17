import 'package:flutter/material.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Activities & Events"),
        backgroundColor: const Color(0xFF4DB6AC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTimelineItem(
              "Tech Talk on Flutter",
              "May 30, 2025",
              "Conducted a session for students about Flutter career paths and best practices.",
              "Workshop",
              "Auditorium A",
            ),
            _buildTimelineItem(
              "Networking Gala",
              "Jun 23, 2025",
              "Participated in the annual alumni networking event for professional growth.",
              "Networking",
              "Virtual Hub",
            ),
            _buildTimelineItem(
              "Code Review Session",
              "Jul 05, 2025",
              "Helped final year students with their project architecture and code quality.",
              "Mentoring",
              "Lab 3",
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, String desc, String type, String loc, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6AC),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: const Color(0xFF4DB6AC).withOpacity(0.3), blurRadius: 6)],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF4DB6AC), const Color(0xFF4DB6AC).withOpacity(0.1)],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(type, style: const TextStyle(color: Color(0xFF00796B), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(desc, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(loc, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
