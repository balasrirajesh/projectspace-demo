import 'package:flutter/material.dart';
import 'package:graduway/widgets/mentorship_request_form.dart';

class MentorshipPage extends StatelessWidget {
  const MentorshipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Mentorship"),
        backgroundColor: const Color(0xFFFFB74D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          children: [
            _buildSectionCard(
              title: "Mentorship Topics",
              child: Column(
                children: [
                  _buildTopicRow("DSA Interview Preparation"),
                  _buildTopicRow("Resume & Portfolio Review"),
                  _buildTopicRow("Career Guidance & Coaching"),
                  _buildTopicRow("Flutter Best Practices"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: "Availability",
              child: _buildDetailRow(Icons.calendar_today, "When", "Saturdays & Sundays (10 AM - 12 PM)"),
            ),
            const SizedBox(height: 24),
            _buildSectionCard(
              title: "Session Info",
              child: Column(
                children: [
                  _buildDetailRow(Icons.videocam_outlined, "Type", "Online (Google Meet)"),
                  _buildDetailRow(Icons.timer_outlined, "Duration", "45 Minutes per session"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    "Looking for guidance?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Alex is happy to help you with your career growth.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const MentorshipRequestForm(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Request Mentorship", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
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
          child,
        ],
      ),
    );
  }

  Widget _buildTopicRow(String topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Text(topic, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
