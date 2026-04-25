import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:graduway/alumni/shared/providers/auth_provider.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  int _currentTab = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentTab => _currentTab;

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  // Stats Data
  int _totalStudents = 0;
  int _totalAlumni = 0;
  int _verifiedAlumni = 0;
  int _totalConnections = 0;
  int _activeSessions = 0;
  int _activeQA = 0;
  int _upcomingEvents = 0;

  int get totalStudents => _totalStudents;
  int get totalAlumni => _totalAlumni;
  int get verifiedAlumni => _verifiedAlumni;
  int get totalConnections => _totalConnections;
  int get activeSessionsCount => _activeSessions;
  int get activeQA => _activeQA;
  int get upcomingEvents => _upcomingEvents;

  // Session Management
  List<dynamic> _activeSessionsSub = []; // renamed to avoid conflict with count
  List<dynamic> get activeSessionsList => _activeSessionsSub;

  // User List
  List<dynamic> _users = [];
  List<dynamic> get users => _users;

  // Connections List
  List<dynamic> _connections = [];
  List<dynamic> get connections => _connections;

  // API Helper
  String _getUrl(String endpoint) =>
      AuthProvider.getBaseUrl('admin/$endpoint');

  Future<void> fetchStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(_getUrl('stats')));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _totalStudents = data['totalStudents'] ?? 0;
        _totalAlumni = data['totalAlumni'] ?? 0;
        _verifiedAlumni = data['verifiedAlumni'] ?? 0;
        _totalConnections = data['totalConnections'] ?? 0;
        _activeSessions = data['activeSessions'] ?? 0;
        _activeQA = data['activeQA'] ?? 0;
        _upcomingEvents = data['upcomingEvents'] ?? 0;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveSessions() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Standardizing to /api/rooms for production proxy support
      final roomsUrl = AuthProvider.getBaseUrl('rooms');

      final response = await http.get(Uri.parse(roomsUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> roomsData = json.decode(response.body);
        _activeSessionsSub = roomsData.entries
            .map((e) => {
                  'id': e.key,
                  'title': e.value['title'] ?? 'General Session',
                  'mentor': e.value['mentorName'] ?? 'Alumni Mentor',
                  'participants': e.value['students']?.length ?? 0,
                  'startTime':
                      e.value['startTime'] ?? DateTime.now().toIso8601String(),
                })
            .toList();
        _activeSessions = _activeSessionsSub.length;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> stopSession(String roomId) async {
    try {
      final response = await http.delete(
        Uri.parse(_getUrl('sessions/$roomId')),
      );
      if (response.statusCode == 200) {
        await fetchActiveSessions();
        await fetchStats();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchUsers(
      {String? role, String? status, String? search}) async {
    _isLoading = true;
    _users = [];
    notifyListeners();
    try {
      String query = '?';
      if (role != null) query += 'role=$role&';
      if (status != null) query += 'status=$status&';
      if (search != null) query += 'search=$search&';

      final response = await http.get(Uri.parse(_getUrl('users$query')));
      if (response.statusCode == 200) {
        _users = json.decode(response.body);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserStatus(String userId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse(_getUrl('users/$userId/status')),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        await fetchUsers(); // Refresh list
        await fetchStats(); // Refresh stats
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> broadcastAnnouncement(
      String title, String message, String target) async {
    try {
      final response = await http.post(
        Uri.parse(_getUrl('announcements')),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'message': message,
          'target': target,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchConnections() async {
    _isLoading = true;
    _connections = [];
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(_getUrl('connections')));
      if (response.statusCode == 200) {
        _connections = json.decode(response.body);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateConnectionStatus(String requestId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse(_getUrl('connections/$requestId')),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      if (response.statusCode == 200) {
        await fetchConnections();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
