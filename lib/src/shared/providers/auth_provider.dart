import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the authentication state and user profile information.
enum UserRole { mentor, student }
enum UserStatus { incomplete, pending, verified, rejected }

class AuthProvider with ChangeNotifier {
  // ──────────────────────────────────────────────────────────────
  //  Server IP Resolution (Dynamic)
  // ──────────────────────────────────────────────────────────────

  static String _serverIp = _defaultIp();

  static String _defaultIp() {
    if (kIsWeb) return 'localhost';
    return '127.0.0.1';
  }

  static String get serverIp => _serverIp;

  static Future<void> resolveServerIp() async {
    // On web, we cannot easily scan local networks due to CORS. 
    // We rely on the SIGNALING_URL from .env or window.location.
    if (kIsWeb) {
      if (_productionSignalingUrl.isNotEmpty) {
        print('🌐 [AUTH] Web mode: Utilizing production signaling URL ($_productionSignalingUrl)');
      } else {
        print('🌐 [AUTH] Web mode: No production URL found, defaulting to localhost');
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('server_ip');
    if (saved != null && saved.isNotEmpty) {
      try {
        final result = await http
            .get(Uri.parse('http://$saved:3000/'))
            .timeout(const Duration(seconds: 1));
        if (result.statusCode < 500) {
          _serverIp = saved;
          return;
        }
      } catch (_) {}
    }

    try {
      final candidates = ['10.34.155.81', 'localhost', '127.0.0.1', '10.0.2.2'];
      for (final ip in candidates) {
        try {
          final result = await http
              .get(Uri.parse('http://$ip:3000/'))
              .timeout(const Duration(seconds: 2));
          if (result.statusCode < 500) {
            _serverIp = ip;
            return;
          }
        } catch (_) {}
      }
    } catch (_) {
      _serverIp = 'localhost';
    }
  }

  static Future<void> saveServerIp(String ip) async {
    _serverIp = ip;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ip);
  }

  static Future<void> clearSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_ip');
    await resolveServerIp();
  }

  // ──────────────────────────────────────────────────────────────
  //  URL Helpers
  // ──────────────────────────────────────────────────────────────

  // Production Signaling URL is now loaded from .env
  static String get _productionSignalingUrl => dotenv.get('SIGNALING_URL', fallback: '');

  static String getBaseUrl(String endpoint) {
    if (_productionSignalingUrl.isNotEmpty) {
      return '${_productionSignalingUrl.replaceAll(RegExp(r'/$'), '')}/api/$endpoint';
    }
    final host = kIsWeb ? 'localhost' : _serverIp;
    return 'http://$host:3000/api/$endpoint';
  }

  static String getSignalingUrl() {
    // Priority: 1. Production URL (from .env)
    if (_productionSignalingUrl.isNotEmpty) {
      String url = _productionSignalingUrl.replaceAll(RegExp(r'/$'), '');
      // Ensure explicit port 443 for production HTTPS to avoid ':0' glitch in some socket clients
      if (url.startsWith('https://') && !url.contains(':', 8)) {
        return '$url:443';
      }
      return url;
    }

    // 2. Fallback: Resolved IP or Localhost
    final host = kIsWeb ? 'localhost' : _serverIp;
    return 'http://$host:3000';
  }

  String get baseUrl => getBaseUrl('auth');

  // ──────────────────────────────────────────────────────────────
  //  Auth State
  // ──────────────────────────────────────────────────────────────

  AuthProvider();

  bool _isLoading = false;
  String? _error;
  bool _isDemoMode = false;
  UserRole _role = UserRole.mentor;
  UserStatus _status = UserStatus.incomplete;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDemoMode => _isDemoMode;
  UserRole get role => _role;
  UserStatus get status => _status;

  String _userName = 'Alex';
  String _techField = 'Flutter Developer';
  String _company = 'Google';
  String _yoe = '5+';
  String? _userId;

  String _fullName = '';
  String _email = '';
  String _phoneNumber = '';
  String _collegeName = '';
  String _branch = '';
  String _graduationYear = '';
  String _bio = '';
  String _profilePictureUrl = '';
  List<String> _skills = [];
  String _linkedInUrl = '';
  String _githubUrl = '';
  String _portfolioUrl = '';

  String get userName => _userName;
  String get techField => _techField;
  String get company => _company;
  String get yoe => _yoe;
  String? get userId => _userId;

  String get fullName => _fullName;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get collegeName => _collegeName;
  String get branch => _branch;
  String get graduationYear => _graduationYear;
  String get bio => _bio;
  String get profilePictureUrl => _profilePictureUrl;
  List<String> get skills => _skills;
  String get linkedInUrl => _linkedInUrl;
  String get githubUrl => _githubUrl;
  String get portfolioUrl => _portfolioUrl;

  Future<bool> login(String email, String password, {bool allowDemoFallback = true}) async {
    _isLoading = true;
    _error = null;
    _isDemoMode = false;
    _role = email.endsWith('@stud.com') ? UserRole.student : UserRole.mentor;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userId = data['id'];
        _userName = data['name'] ?? 'User';
        _techField = data['techField'] ?? _techField;
        _company = data['company'] ?? _company;
        _yoe = data['yoe'] ?? _yoe;
        _fullName = data['fullName'] ?? '';
        _collegeName = data['collegeName'] ?? '';
        _status = _mapStatus(data['status']);
        _isDemoMode = false;
        notifyListeners();
        return true;
      } else {
        if (allowDemoFallback && email.isNotEmpty) return _fallbackToDemo(email);
        _error = 'Server error (${response.statusCode})';
        return false;
      }
    } catch (e) {
      if (allowDemoFallback && email.isNotEmpty) return _fallbackToDemo(email);
      _error = 'Connection error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserStatus _mapStatus(String? status) {
    switch (status) {
      case 'VERIFIED': return UserStatus.verified;
      case 'PENDING': return UserStatus.pending;
      case 'REJECTED': return UserStatus.rejected;
      default: return UserStatus.incomplete;
    }
  }

  bool _fallbackToDemo(String email) {
    _isDemoMode = true;
    _role = email.endsWith('@stud.com') ? UserRole.student : UserRole.mentor;
    _userId = '${DateTime.now().millisecondsSinceEpoch}';
    _email = email;
    String rawName = email.contains('@') ? email.split('@')[0] : email;
    _userName = rawName
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '')
        .join(' ');
    
    if (_userName.isEmpty) _userName = 'Demo User';
    _status = UserStatus.incomplete; 
    _techField = 'Alumni Mentor';
    _company = 'Tech Demo Corp';
    _error = null;
    notifyListeners();
    return true;
  }

  Future<void> updateProfile({
    String? name,
    String? fullName,
    String? phoneNumber,
    String? collegeName,
    String? branch,
    String? graduationYear,
    String? bio,
    String? currentJob,
    String? company,
    List<String>? skills,
    String? pfpUrl,
    String? linkedInUrl,
    String? githubUrl,
    String? portfolioUrl,
  }) async {
    if (name != null) _userName = name;
    if (fullName != null) _fullName = fullName;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (collegeName != null) _collegeName = collegeName;
    if (branch != null) _branch = branch;
    if (graduationYear != null) _graduationYear = graduationYear;
    if (bio != null) _bio = bio;
    if (currentJob != null) _techField = currentJob;
    if (company != null) _company = company;
    if (skills != null) _skills = skills;
    if (pfpUrl != null) _profilePictureUrl = pfpUrl;
    if (linkedInUrl != null) _linkedInUrl = linkedInUrl;
    if (githubUrl != null) _githubUrl = githubUrl;
    if (portfolioUrl != null) _portfolioUrl = portfolioUrl;
    
    if (_status == UserStatus.incomplete) {
      _status = UserStatus.pending;
    }
    notifyListeners();
  }

  Future<void> submitForVerification() async {
    _status = UserStatus.pending;
    notifyListeners();
    if (_isDemoMode) {
      Future.delayed(const Duration(seconds: 15), () {
        _status = UserStatus.verified;
        notifyListeners();
      });
    }
  }

  bool get canAccessPremiumFeatures => _status == UserStatus.verified;
}
