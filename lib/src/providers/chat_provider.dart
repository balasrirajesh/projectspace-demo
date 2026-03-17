import 'package:flutter/material.dart';
import 'package:alumini_screen/src/models/chat_model.dart';
import 'package:alumini_screen/src/services/mentorship_service.dart';

class ChatProvider with ChangeNotifier {
  final MentorshipService _service = MentorshipService();
  
  // Maps ChatId to list of messages
  final Map<String, List<ChatMessage>> _messages = {};
  
  // Maps MenteeId to unread count
  final Map<String, int> _unreadCounts = {};

  Map<String, List<ChatMessage>> get messages => _messages;

  List<ChatMessage> getMessages(String chatId) => _messages[chatId] ?? [];

  int getUnreadCount(String menteeId) => _unreadCounts[menteeId] ?? 0;

  void sendMessage(String chatId, ChatMessage message) {
    _service.sendMessage(chatId, message);
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
    }
    _messages[chatId]!.add(message);
    notifyListeners();
  }

  void markAsRead(String menteeId) {
    _unreadCounts[menteeId] = 0;
    notifyListeners();
  }

  void incrementUnread(String menteeId) {
    _unreadCounts[menteeId] = (_unreadCounts[menteeId] ?? 0) + 1;
    notifyListeners();
  }
}
