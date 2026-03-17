import 'package:flutter/material.dart';
import 'package:alumini_screen/src/models/mentorship_model.dart';
import 'package:alumini_screen/src/services/mentorship_service.dart';

class MentorshipProvider with ChangeNotifier {
  final MentorshipService _service = MentorshipService();
  
  List<MentorshipRequest> _allRequests = [];
  
  MentorshipProvider() {
    _init();
  }

  void _init() {
    // Seed data for demo if needed
    _service.seedData();
    _allRequests = _service.getRequests();
    
    // Listen to service updates
    _service.requestsStream.listen((updatedRequests) {
      _allRequests = updatedRequests;
      notifyListeners();
    });
  }

  // Getters for specific filtered lists
  List<MentorshipRequest> get pendingRequests => 
      _allRequests.where((r) => r.status == MentorshipStatus.pending).toList();

  List<MentorshipRequest> get acceptedMentees => 
      _allRequests.where((r) => r.status == MentorshipStatus.accepted).toList();

  int get pendingCount => pendingRequests.length;
  int get acceptedCount => acceptedMentees.length;

  // Actions
  void acceptRequest(String id) {
    _service.updateRequestStatus(id, MentorshipStatus.accepted);
    // notifyListeners() is called by the stream listener in _init()
  }

  void rejectRequest(String id) {
    _service.updateRequestStatus(id, MentorshipStatus.rejected);
  }
}
