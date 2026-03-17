import 'package:flutter/material.dart';

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

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n['isRead']).length;

  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
