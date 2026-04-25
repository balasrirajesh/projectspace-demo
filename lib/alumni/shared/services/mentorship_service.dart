import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:graduway/alumni/shared/models/mentorship_model.dart';
import 'package:graduway/alumni/shared/models/chat_model.dart';
import 'package:flutter/foundation.dart';

import 'package:graduway/alumni/shared/providers/auth_provider.dart';

/// Singleton service that manages mentorship requests and chat message streams.
///
/// Updated to communicate with Spring Boot backend.
class MentorshipService {
  static final MentorshipService _instance = MentorshipService._internal();
  factory MentorshipService() => _instance;
  MentorshipService._internal();

  final String baseUrl = AuthProvider.getBaseUrl("mentorship");
  final List<MentorshipRequest> _requests = [];
  final Map<String, List<ChatMessage>> _chats = {};

  final _controller = StreamController<List<MentorshipRequest>>.broadcast();
  final _chatControllers = <String, StreamController<List<ChatMessage>>>{};

  /// A broadcast stream of all mentorship requests.
  Stream<List<MentorshipRequest>> get requestsStream => _controller.stream;

  /// Fetches all requests from the backend and updates the stream.
  Future<void> fetchRequests({String? studentId, String? mentorId}) async {
    try {
      String url = "$baseUrl/requests";
      if (studentId != null)
        url += "?studentId=$studentId";
      else if (mentorId != null) url += "?mentorId=$mentorId";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _requests.clear();
        _requests.addAll(
            data.map((json) => MentorshipRequest.fromJson(json)).toList());
        _controller.add(List.unmodifiable(_requests));
      }
    } catch (e) {
      debugPrint("Error fetching requests: $e");
    }
  }

  /// Returns a broadcast stream for a specific chat session.
  Stream<List<ChatMessage>> getChatStream(String chatId) {
    if (!_chatControllers.containsKey(chatId)) {
      _chatControllers[chatId] =
          StreamController<List<ChatMessage>>.broadcast();
    }
    return _chatControllers[chatId]!.stream;
  }

  /// Submits a new mentorship request to the backend.
  Future<void> submitRequest(MentorshipRequest request) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/requests"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(request.toJson()),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchRequests();
      }
    } catch (e) {
      debugPrint("Error submitting request: $e");
    }
  }

  /// Updates the status of an existing request in the backend.
  Future<void> updateRequestStatus(String id, MentorshipStatus status) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/requests/$id/status"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"status": status.name}),
      );
      if (response.statusCode == 200) {
        await fetchRequests();
      }
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  /// Convenience method to mark a mentorship as 'ended'.
  void endMentorship(String id) {
    updateRequestStatus(id, MentorshipStatus.ended);
  }

  /// Returns an unmodifiable list of all current requests.
  List<MentorshipRequest> getRequests() => List.unmodifiable(_requests);

  /// Sends a message in a specific chat session and updates the corresponding stream.
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    try {
      final response = await http.post(
        Uri.parse("${AuthProvider.getBaseUrl("chats")}/$chatId/messages"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(message.toJson()),
      );
      if (response.statusCode == 200) {
        // In a real app, we'd wait for WebSocket/SSE, but for now we poll or push
        if (!_chats.containsKey(chatId)) {
          _chats[chatId] = [];
        }
        _chats[chatId]!.add(ChatMessage.fromJson(json.decode(response.body)));
        _chatControllers[chatId]?.add(List.unmodifiable(_chats[chatId]!));
      }
    } catch (e) {
      debugPrint("Error sending message: $e");
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

  /// Seeds the service with initial mock data (now handled by backend).
  Future<void> seedData() async {
    await fetchRequests();
  }

  /// Creates a new persistent webinar session in the backend.
  Future<bool> createWebinar({
    required String title,
    required String mentorId,
    required String mentorName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${AuthProvider.getBaseUrl("rooms")}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "id": title.toLowerCase().replaceAll(' ', '-'),
          "title": title,
          "mentorId": mentorId,
          "mentorName": mentorName,
          "startTime": DateTime.now().toIso8601String(),
          "isLive": true,
          "attendees": 0,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Error creating webinar: $e");
      return false;
    }
  }
}
