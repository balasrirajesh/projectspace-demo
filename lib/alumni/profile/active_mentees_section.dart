import 'package:graduway/alumni/chat/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
import 'package:graduway/alumni/shared/models/mentorship_model.dart';

class ActiveMenteesSection extends StatelessWidget {
  const ActiveMenteesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mentorship = context.watch<MentorshipProvider>();
    final activeMentees = mentorship.acceptedMentees;

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
              child: Text("Provide guidance to start seeing mentees here.",
                  style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...activeMentees
              .take(2)
              .map((mentee) => _buildMenteeCard(context, mentee)),
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
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: Text(mentee.student.name[0],
                  style: const TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mentee.student.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(mentee.topics.first,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
