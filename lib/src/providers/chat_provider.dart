import 'package:flutter/material.dart';
import 'package:alumini_screen/src/models/chat_model.dart';
import 'package:alumini_screen/src/services/mentorship_service.dart';
import 'package:alumini_screen/src/services/persistence_service.dart';

/// Manages the state of chat conversations, including message history and unread counts.
/// 
/// This provider handles sending messages, receiving updates from the mentorship service,
/// and persisting chat data to local storage.
class ChatProvider with ChangeNotifier {
  final MentorshipService _service = MentorshipService();
  final PersistenceService _persistence = PersistenceService();
  
  bool _isLoading = false;
  String? _error;

  /// Whether a chat operation is currently in progress.
  bool get isLoading => _isLoading;

  /// The latest error encountered during chat operations.
  String? get error => _error;
  
  /// Internal map of chat ID to its list of messages.
  final Map<String, List<ChatMessage>> _messages = {};
  
  /// Internal map of mentee ID to their unread message count.
  final Map<String, int> _unreadCounts = {};

  ChatProvider() {
    loadFromLocal();
  }

  /// Persists the current chat messages and unread counts to local storage.
  Future<void> saveToLocal() async {
    final messagesData = _messages.map((key, value) => MapEntry(key, value.map((m) => m.toJson()).toList()));
    await _persistence.saveData('chat_messages', messagesData);
    await _persistence.saveData('unread_counts', _unreadCounts);
  }

  /// Loads chat messages and unread counts from local storage.
  Future<void> loadFromLocal() async {
    final mData = await _persistence.getData('chat_messages');
    if (mData != null && mData is Map) {
      mData.forEach((key, value) {
        if (value is List) {
          _messages[key.toString()] = value.map((json) => ChatMessage.fromJson(Map<String, dynamic>.from(json))).toList();
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

  /// Initializes a new chat session for a given mentee if it doesn't already exist.
  void createSession(dynamic mentee) {
    final chatId = "chat_${mentee.id}";
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
      saveToLocal();
      notifyListeners();
    }
  }

  /// Returns a map of all chat sessions and their messages.
  Map<String, List<ChatMessage>> get messages => _messages;

  /// Retrieves the list of messages for a specific chat session.
  List<ChatMessage> getMessages(String chatId) => _messages[chatId] ?? [];

  /// Gets the unread message count for a specific mentee.
  int getUnreadCount(String menteeId) => _unreadCounts[menteeId] ?? 0;

  /// Sends a new message in a chat session and updates local storage.
  void sendMessage(String chatId, ChatMessage message) {
    _service.sendMessage(chatId, message);
    if (!_messages.containsKey(chatId)) {
      _messages[chatId] = [];
    }
    _messages[chatId]!.add(message);
    saveToLocal();
    notifyListeners();
  }

  /// Resets the unread message count to zero for a specific mentee.
  void markAsRead(String menteeId) {
    _unreadCounts[menteeId] = 0;
    saveToLocal();
    notifyListeners();
  }

  /// Increments the unread message count for a specific mentee.
  void incrementUnread(String menteeId) {
    _unreadCounts[menteeId] = (_unreadCounts[menteeId] ?? 0) + 1;
    saveToLocal();
    notifyListeners();
  }
}
