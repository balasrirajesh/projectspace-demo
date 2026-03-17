import 'package:flutter/material.dart';
import 'package:alumini_screen/src/models/mentorship_model.dart';
import 'package:alumini_screen/src/services/mentorship_service.dart';
import 'package:alumini_screen/src/widgets/mentorship_request_card.dart';

class AlumniRequestsPage extends StatefulWidget {
  const AlumniRequestsPage({super.key});

  @override
  State<AlumniRequestsPage> createState() => _AlumniRequestsPageState();
}

class _AlumniRequestsPageState extends State<AlumniRequestsPage> {
  final MentorshipService _service = MentorshipService();

  @override
  void initState() {
    super.initState();
    _service.seedData(); // Ensure we have some data to show
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
      body: StreamBuilder<List<MentorshipRequest>>(
        stream: _service.requestsStream,
        initialData: _service.getRequests(),
        builder: (context, snapshot) {
          final requests = snapshot.data ?? [];
          
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pending_actions, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "No pending requests",
                    style: TextStyle(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.bold),
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
                onAccept: () => _updateStatus(request.id, MentorshipStatus.accepted),
                onReject: () {
                  if (request.status == MentorshipStatus.accepted) {
                    _updateStatus(request.id, MentorshipStatus.ended);
                  } else {
                    _updateStatus(request.id, MentorshipStatus.rejected);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  void _updateStatus(String id, MentorshipStatus status) {
    setState(() {
      _service.updateRequestStatus(id, status);
    });
    
    String message;
    if (status == MentorshipStatus.accepted) {
      message = "Request accepted! Chat is now enabled.";
    } else if (status == MentorshipStatus.rejected) {
      message = "Request rejected.";
    } else {
      message = "Mentorship ended.";
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: status == MentorshipStatus.accepted 
          ? Colors.green 
          : (status == MentorshipStatus.ended ? Colors.grey[800] : Colors.red),
      ),
    );
  }
}
