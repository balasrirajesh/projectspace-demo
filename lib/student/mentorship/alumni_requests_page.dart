import 'package:graduway/alumni/mentorship/mentorship_request_card.dart';
import 'package:flutter/material.dart';
import 'package:graduway/alumni/shared/models/mentorship_model.dart';
import 'package:provider/provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';

/// A page that displays a list of pending mentorship requests for an alumni mentor.
///
/// Mentors can review, accept, or reject incoming requests from students.
/// Accepting a request enables chat functionality between the mentor and student.
class AlumniRequestsPage extends StatefulWidget {
  const AlumniRequestsPage({super.key});

  @override
  State<AlumniRequestsPage> createState() => _AlumniRequestsPageState();
}

class _AlumniRequestsPageState extends State<AlumniRequestsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Mentorship Requests"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<MentorshipProvider>(
        builder: (context, mentorship, _) {
          final requests = mentorship.pendingRequests;

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pending_actions,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "No pending requests",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return MentorshipRequestCard(
                request: request,
                onAccept: () => _handleStatusChange(
                    context, mentorship, request.id, MentorshipStatus.accepted),
                onReject: () => _handleStatusChange(
                    context, mentorship, request.id, MentorshipStatus.rejected),
              );
            },
          );
        },
      ),
    );
  }

  /// Handles the acceptance or rejection of a mentorship request.
  ///
  /// Updates the request status via [MentorshipProvider] and shows a confirmation [SnackBar].
  void _handleStatusChange(BuildContext context, MentorshipProvider provider,
      String id, MentorshipStatus status) {
    if (status == MentorshipStatus.accepted) {
      provider.acceptRequest(id);
    } else {
      provider.rejectRequest(id);
    }

    String message = status == MentorshipStatus.accepted
        ? "Request accepted! Chat is now enabled."
        : "Request rejected.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            status == MentorshipStatus.accepted ? Colors.green : Colors.red,
      ),
    );
  }
}
