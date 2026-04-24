import 'package:flutter/material.dart';
import 'package:graduway/alumni/shared/models/mentorship_model.dart';
import 'package:graduway/alumni/shared/services/mentorship_service.dart';

/// A card widget that displays details of a mentorship request.
///
/// It includes student info (name, branch, skills), the request reason,
/// and action buttons (Accept/Reject) if the request is still pending.
/// It also displays mock AI suggestion chips for quick responses.
class MentorshipRequestCard extends StatelessWidget {
  /// The mentorship request data to display.
  final MentorshipRequest request;

  /// Callback when the 'Accept' button is tapped.
  final VoidCallback onAccept;

  /// Callback when the 'Reject' or 'End Mentorship' button is tapped.
  final VoidCallback onReject;

  const MentorshipRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(
                    request.student.name[0],
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.student.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${request.student.branch} • ${request.student.year}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Skills:",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: request.student.skills
                  .map((skill) => _buildSkillChip(skill))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              "Message:",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              request.reason,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            const Text(
              "Topics:",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: request.topics
                  .map((topic) => _buildTopicChip(topic))
                  .toList(),
            ),
            if (request.status == MentorshipStatus.pending) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Reject"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text("Accept"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "AI Suggestions:",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MentorshipService()
                      .getReplySuggestions(request)
                      .map((suggestion) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                      ),
                      child: Text(
                        suggestion,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (request.status == MentorshipStatus.accepted) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onReject, // Reusing onReject logic for 'Ending'
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  label: const Text("End Mentorship"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a colored badge representing the current status of the request.
  Widget _buildStatusBadge() {
    Color color;
    String text;
    switch (request.status) {
      case MentorshipStatus.pending:
        color = Colors.orange;
        text = "Pending";
        break;
      case MentorshipStatus.accepted:
        color = Colors.green;
        text = "Accepted";
        break;
      case MentorshipStatus.rejected:
        color = Colors.red;
        text = "Rejected";
        break;
      case MentorshipStatus.ended:
        color = Colors.grey;
        text = "Completed";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  /// Builds a chip for displaying a student skill.
  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        skill,
        style: const TextStyle(fontSize: 11, color: Colors.blue),
      ),
    );
  }

  /// Builds a chip for displaying a mentorship topic.
  Widget _buildTopicChip(String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        topic,
        style: const TextStyle(fontSize: 11, color: Colors.orange),
      ),
    );
  }
}
