import 'package:flutter/material.dart';
import 'package:graduway/alumni/shared/models/chat_model.dart';
import 'package:graduway/alumni/shared/services/mentorship_service.dart';
import 'package:graduway/alumni/shared/services/persistence_service.dart';

/// Manages the state of chat conversations, including message history and unread counts.
class ChatProvider with ChangeNotifier {
  final MentorshipService _service = MentorshipService();
  final PersistenceService _persistence = PersistenceService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  final Map<String, List<ChatMessage>> _messages = {};
  final Map<String, int> _unreadCounts = {};

  ChatProvider() {
    loadFromLocal();
  }

  Future<void> saveToLocal() async {
    final messagesData = _messages.map(
        (key, value) => MapEntry(key, value.map((m) => m.toJson()).toList()));
    await _persistence.saveData('chat_messages', messagesData);
    await _persistence.saveData('unread_counts', _unreadCounts);
  }

  Future<void> loadFromLocal() async {
    final mData = await _persistence.getData('chat_messages');
    if (mData != null && mData is Map) {
      mData.forEach((key, value) {
        if (value is List) {
          _messages[key.toString()] = value
              .map((json) =>
                  ChatMessage.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }
      });
    }
    final uData = await _persistence.getData('unread_counts');
    if (uData != null && uData is Map) {
      uData.forEach((key, value) {
        _unreadCounts[key.toString()] = value as int;
      });
    }
    notifyListeners();
  }

  void createSession(dynamic mentee) {
    final chatId = "chat_${mentee.id}";
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
      saveToLocal();
      notifyListeners();
    }
  }

  Map<String, List<ChatMessage>> get messages => _messages;

  List<ChatMessage> getMessages(String chatId) => _messages[chatId] ?? [];

  int getUnreadCount(String menteeId) => _unreadCounts[menteeId] ?? 0;

  Future<void> sendMessage(String chatId, ChatMessage message) async {
    await _service.sendMessage(chatId, message);
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
    }
    _messages[chatId]!.add(message);
    saveToLocal();
    notifyListeners();
  }

  void markAsRead(String menteeId) {
    _unreadCounts[menteeId] = 0;
    saveToLocal();
    notifyListeners();
  }

  void incrementUnread(String menteeId) {
    _unreadCounts[menteeId] = (_unreadCounts[menteeId] ?? 0) + 1;
    saveToLocal();
    notifyListeners();
  }
}
