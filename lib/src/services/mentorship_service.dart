import 'dart:async';
import 'package:alumini_screen/src/models/mentorship_model.dart';
import 'package:alumini_screen/src/models/chat_model.dart';

/// Singleton service that manages mentorship requests and chat message streams.
/// 
/// This service acts as the central hub for submitting requests, updating their status,
/// and handling real-time chat updates via streams.
class MentorshipService {
  static final MentorshipService _instance = MentorshipService._internal();
  factory MentorshipService() => _instance;
  MentorshipService._internal();

  final List<MentorshipRequest> _requests = [];
  final Map<String, List<ChatMessage>> _chats = {};
  
  final _controller = StreamController<List<MentorshipRequest>>.broadcast();
  final _chatControllers = <String, StreamController<List<ChatMessage>>>{};

  /// A broadcast stream of all mentorship requests.
  Stream<List<MentorshipRequest>> get requestsStream => _controller.stream;
  
  /// Returns a broadcast stream for a specific chat session.
  /// 
  /// If the stream doesn't exist, it creates one and pushes any existing messages.
  Stream<List<ChatMessage>> getChatStream(String chatId) {
    if (!_chatControllers.containsKey(chatId)) {
      _chatControllers[chatId] = StreamController<List<ChatMessage>>.broadcast();
      // Add initial data if exists
      if (_chats.containsKey(chatId)) {
        _chatControllers[chatId]!.add(List.unmodifiable(_chats[chatId]!));
      }
    }
    return _chatControllers[chatId]!.stream;
  }

  /// Submits a new mentorship request and notifies listeners via the stream.
  void submitRequest(MentorshipRequest request) {
    _requests.add(request);
    _controller.add(List.unmodifiable(_requests));
  }

  /// Updates the status of an existing request and broadcasts the change.
  void updateRequestStatus(String id, MentorshipStatus status) {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: status);
      _controller.add(List.unmodifiable(_requests));
    }
  }

  /// Convenience method to mark a mentorship as 'ended'.
  void endMentorship(String id) {
    updateRequestStatus(id, MentorshipStatus.ended);
  }

  /// Returns an unmodifiable list of all current requests.
  List<MentorshipRequest> getRequests() => List.unmodifiable(_requests);

  /// Sends a message in a specific chat session and updates the corresponding stream.
  void sendMessage(String chatId, ChatMessage message) {
    if (!_chats.containsKey(chatId)) {
      _chats[chatId] = [];
    }
    _chats[chatId]!.add(message);
    
    if (_chatControllers.containsKey(chatId)) {
      _chatControllers[chatId]!.add(List.unmodifiable(_chats[chatId]!));
    }
  }

  /// Returns an unmodifiable list of messages for a specific chat session.
  List<ChatMessage> getMessages(String chatId) {
    return List.unmodifiable(_chats[chatId] ?? []);
  }
  
  /// Mock AI Logic: Provides a set of suggested replies for a given request.
  List<String> getReplySuggestions(MentorshipRequest request) {
    return [
      "Hi ${request.student.name}, I'd love to help with your request on ${request.topics.first}!",
      "Hello! Your background in ${request.student.skills.first} looks great. Happy to mentor you.",
      "I'm available during your preferred schedule. Let's connect!",
    ];
  }

  /// Seeds the service with initial mock data for demonstration purposes.
  void seedData() {
    if (_requests.isEmpty) {
      submitRequest(MentorshipRequest(
        id: "1",
        student: Student(
          id: "s1",
          name: "John Doe",
          branch: "Computer Science",
          year: "3rd Year",
          skills: ["Flutter", "Dart", "Firebase"],
        ),
        reason: "I want to learn more about architecture patterns in Flutter.",
        topics: ["Flutter Best Practices", "Resume & Portfolio Review"],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ));
    }
  }
}

