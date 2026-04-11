import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alumini_screen/src/shared/models/mentorship_model.dart';
import 'package:alumini_screen/src/shared/services/mentorship_service.dart';
import 'package:alumini_screen/src/shared/services/persistence_service.dart';
import 'package:alumini_screen/src/shared/providers/chat_provider.dart';

/// Manages the state of mentorship requests and sessions.
/// 
/// This provider handles loading requests from the service, filtering them by status,
/// and performing actions like accepting or rejecting requests. It also stays
/// synchronized with the [ChatProvider] to create sessions when requests are accepted.
class MentorshipProvider with ChangeNotifier {
  final MentorshipService _service = MentorshipService();
  final PersistenceService _persistence = PersistenceService();
  ChatProvider? _chatProvider;
  StreamSubscription? _subscription;

  bool _isLoading = false;
  String? _error;

  /// Whether a mentorship operation is currently in progress.
  bool get isLoading => _isLoading;

  /// The latest error encountered during mentorship operations.
  String? get error => _error;
  
  List<MentorshipRequest> _allRequests = [];
  List<Map<String, dynamic>> _webinars = [
    {
      'id': 'w1',
      'title': 'Advanced Flutter UI Patterns',
      'startTime': 'Today, 6:00 PM',
      'isLive': false,
      'attendees': 45,
    },
    {
      'id': 'w2',
      'title': 'Career Transitions in Tech',
      'startTime': 'Live Now',
      'isLive': true,
      'attendees': 120,
    }
  ];

  /// Returns a list of all mentorship requests.
  List<MentorshipRequest> get allRequests => _allRequests;

  /// Returns current and upcoming webinars/classes.
  List<Map<String, dynamic>> get webinars => _webinars;

  /// Sets the [ChatProvider] instance to be used for creating chat sessions.
  void setChatProvider(ChatProvider chatProvider) {
    _chatProvider = chatProvider;
  }
  
  MentorshipProvider() {
    _init();
  }

  /// Initializes the provider by loading data from local storage or seeding for demo.
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    // Try to load from local first
    await loadFromLocal();
    
    // Always sync with service to get latest from backend
    await _service.seedData();
    _allRequests = _service.getRequests();
    await saveToLocal();
    
    // Listen to service updates
    _subscription = _service.requestsStream.listen((updatedRequests) {
      _allRequests = updatedRequests;
      saveToLocal();
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  /// Persists the current list of mentorship requests to local storage.
  Future<void> saveToLocal() async {
    final data = _allRequests.map((r) => r.toJson()).toList();
    await _persistence.saveData('mentorship_requests', data);
  }

  /// Loads mentorship requests from local storage.
  Future<void> loadFromLocal() async {
    final data = await _persistence.getData('mentorship_requests');
    if (data != null && data is List) {
      _allRequests = data.map((json) => MentorshipRequest.fromJson(json)).toList();
      notifyListeners();
    }
  }

  /// Returns a list of requests that are currently in the 'pending' status.
  List<MentorshipRequest> get pendingRequests => 
      _allRequests.where((r) => r.status == MentorshipStatus.pending).toList();

  /// Returns a list of mentees whose requests have been 'accepted'.
  List<MentorshipRequest> get acceptedMentees => 
      _allRequests.where((r) => r.status == MentorshipStatus.accepted).toList();

  /// The count of pending mentorship requests.
  int get pendingCount => pendingRequests.length;

  /// The count of accepted mentorship sessions.
  int get acceptedCount => acceptedMentees.length;

  /// Accepts a mentorship request by ID and creates a corresponding chat session.
  Future<void> acceptRequest(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = _allRequests.firstWhere((r) => r.id == id);
      await _service.updateRequestStatus(id, MentorshipStatus.accepted);
      
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

  /// Rejects a mentorship request by ID.
  Future<void> rejectRequest(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.updateRequestStatus(id, MentorshipStatus.rejected);
      await saveToLocal();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Starts a new webinar session.
  void startNewWebinar(String title) {
    _webinars.insert(0, {
      'id': 'w${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'startTime': 'Started Just Now',
      'isLive': true,
      'attendees': 0,
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

