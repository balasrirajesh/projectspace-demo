import 'package:flutter/material.dart';
import 'package:alumini_screen/src/models/mentorship_model.dart';
import 'package:alumini_screen/src/services/mentorship_service.dart';
import 'package:alumini_screen/src/services/persistence_service.dart';
import 'package:alumini_screen/src/providers/chat_provider.dart';

class MentorshipProvider with ChangeNotifier {
  final MentorshipService _service = MentorshipService();
  final PersistenceService _persistence = PersistenceService();
  ChatProvider? _chatProvider;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<MentorshipRequest> _allRequests = [];

  void setChatProvider(ChatProvider chatProvider) {
    _chatProvider = chatProvider;
  }
  
  MentorshipProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    // Try to load from local first
    await loadFromLocal();
    
    // If empty, seed data for demo
    if (_allRequests.isEmpty) {
      _service.seedData();
      _allRequests = _service.getRequests();
      await saveToLocal();
    }
    
    // Listen to service updates
    _service.requestsStream.listen((updatedRequests) {
      _allRequests = updatedRequests;
      saveToLocal();
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveToLocal() async {
    final data = _allRequests.map((r) => r.toJson()).toList();
    await _persistence.saveData('mentorship_requests', data);
  }

  Future<void> loadFromLocal() async {
    final data = await _persistence.getData('mentorship_requests');
    if (data != null && data is List) {
      _allRequests = data.map((json) => MentorshipRequest.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Getters for specific filtered lists
  List<MentorshipRequest> get pendingRequests => 
      _allRequests.where((r) => r.status == MentorshipStatus.pending).toList();

  List<MentorshipRequest> get acceptedMentees => 
      _allRequests.where((r) => r.status == MentorshipStatus.accepted).toList();

  int get pendingCount => pendingRequests.length;
  int get acceptedCount => acceptedMentees.length;

  // Actions
  Future<void> acceptRequest(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = _allRequests.firstWhere((r) => r.id == id);
      _service.updateRequestStatus(id, MentorshipStatus.accepted);
      
      // Link with ChatProvider
      if (_chatProvider != null) {
        _chatProvider!.createSession(request.student);
      }
      await saveToLocal();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectRequest(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _service.updateRequestStatus(id, MentorshipStatus.rejected);
      await saveToLocal();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
