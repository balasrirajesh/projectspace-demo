import 'package:flutter/material.dart';

/// Manages the lifecycle of in-app notifications.
/// 
/// This provider stores a list of notifications, tracks unread counts,
/// and provides methods to add, mark as read, or clear notifications.
class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'New Request',
      'body': 'John Doe sent you a mentorship request.',
      'time': '2m ago',
      'isRead': false,
    }
  ];

  /// The list of all notifications.
  List<Map<String, dynamic>> get notifications => _notifications;

  /// The count of notifications that haven't been read yet.
  int get unreadCount => _notifications.where((n) => !n['isRead']).length;

  /// Adds a new notification to the beginning of the list and notifies listeners.
  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Marks a specific notification as read by its ID.
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  /// Removes all notifications from the list.
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}

