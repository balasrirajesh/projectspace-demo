import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduway/models/user_role.dart';

/// Manages the authentication state and user profile information.
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

  static bool _isAdmin = false;
  static bool get isUserAdmin => _isAdmin;

  static String get serverIp => _serverIp;

  static Future<void> resolveServerIp() async {
    // 1. Production override (e.g. Jenkins/OpenShift build ENV)
    if (_productionSignalingUrl.isNotEmpty) {
      dev.log(
          '🌐 [AUTH] Production URL detected: $_productionSignalingUrl. Skipping local discovery.');
      return;
    }

    // 2. Web mode (Localhost is always the default for web dev)
    if (kIsWeb) {
      _serverIp = 'localhost';
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // 3. Fast Path: Try cached IP first
    final saved = prefs.getString('server_ip');
    if (saved != null && saved.isNotEmpty) {
      if (await _probeIp(saved, timeout: 800)) {
        _serverIp = saved;
        dev.log('⚡ [AUTH] Quick-connect to cached server: $_serverIp');
        return;
      }
    }

    // 4. Slow Path: Dynamic Discovery
    dev.log('🌐 [AUTH] Discovery: Starting local network scan...');

    // Static fallback candidates (Emulators, etc.)
    final List<String> candidates = ['localhost', '127.0.0.1', '10.0.2.2'];

    try {
      final interfaces = await NetworkInterface.list(
          includeLoopback: false, type: InternetAddressType.IPv4);

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          final parts = addr.address.split('.');
          if (parts.length == 4) {
            final String subnet = parts.sublist(0, 3).join('.');
            final int deviceLastOctet = int.parse(parts[3]);

            // Add common targets relative to current IP
            candidates.add('$subnet.1'); // Gateway/Potential Dev PC
            candidates.add('$subnet.100'); // Common lease start

            // Probe a small window around the device (covers most home/lab setups)
            for (int i = -10; i <= 10; i++) {
              int target = deviceLastOctet + i;
              if (target > 0 && target < 255) candidates.add('$subnet.$target');
            }
          }
        }
      }
    } catch (e) {
      dev.log('⚠️ [AUTH] Network scan failed: $e');
    }

    // Deduplicate and probe
    final uniqueCandidates = candidates.toSet().toList();

    // Sort to prioritize previously used or common IPs
    uniqueCandidates.sort((a, b) {
      if (a == '10.0.2.2') return -1; // Prioritize Android emulator bridge
      return 0;
    });

    for (final ip in uniqueCandidates) {
      if (await _probeIp(ip, timeout: 600)) {
        _serverIp = ip;
        await saveServerIp(ip);
        dev.log('✅ [AUTH] Discovery success: $ip');
        return;
      }
    }

    dev.log('❌ [AUTH] Discovery failed. Using localhost fallback.');
    _serverIp = 'localhost';
  }

  /// Pings an IP to see if the signaling server is listening
  static Future<bool> _probeIp(String ip, {int timeout = 1000}) async {
    try {
      final result = await http
          .get(Uri.parse('http://$ip:3000/'))
          .timeout(Duration(milliseconds: timeout));
      return result.statusCode < 500;
    } catch (_) {
      return false;
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
  static String get _productionSignalingUrl =>
      dotenv.get('SIGNALING_URL', fallback: '');

  // Local Signaling URL fallback
  static String get _localSignalingUrl =>
      dotenv.get('LOCAL_SIGNALING_URL', fallback: 'http://localhost:3000');

  static String getBaseUrl(String endpoint) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    // Priority 1: Smart Debug Fallback for Local Development
    if (kDebugMode && kIsWeb) {
      return '$_localSignalingUrl/api$cleanEndpoint';
    }

    // Priority 2: Production URL (from .env)
    if (_productionSignalingUrl.isNotEmpty) {
      String base = _productionSignalingUrl.replaceAll(RegExp(r'/$'), '');
      return "$base/api$cleanEndpoint";
    }

    // Priority 3: Fallback: Resolved IP or Localhost
    final host = kIsWeb ? 'localhost' : _serverIp;
    return 'http://$host:3000/api$cleanEndpoint';
  }

  static String getSignalingUrl() {
    // Priority 1: Smart Debug Fallback for Local Development
    // If we're on web (localhost) and in debug mode, prefer local server directly
    if (kDebugMode && kIsWeb) {
      return _localSignalingUrl;
    }

    // Priority 2: Production URL (from .env) if provided
    if (_productionSignalingUrl.isNotEmpty) {
      return _productionSignalingUrl.replaceAll(RegExp(r'/$'), '');
    }

    // Priority 3: Fallback: Resolved IP or Localhost
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
  bool get isAuthenticated => _userId != null;
  bool _forceSetup = false;
  bool get forceSetup => _forceSetup;

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

  Future<bool> login(String email, String password,
      {bool allowDemoFallback = true}) async {
    _isLoading = true;
    _error = null;
    _isDemoMode = false;

    final lowEmail = email.toLowerCase();
    _role = lowEmail.endsWith('@admin.com')
        ? UserRole.admin
        : (lowEmail.endsWith('@alumni.com')
            ? UserRole.mentor
            : (lowEmail.endsWith('@stud.com') ? UserRole.student : UserRole.student));
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'password': password,
              'name': email.split('@')[0]
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userId = data['id'];
        _userName = data['name'] ?? 'User';
        _email = data['email'] ?? email;
        _techField = data['techField'] ?? _techField;
        _company = data['company'] ?? _company;
        _yoe = data['yoe'] ?? '0';
        _status = _mapStatus(data['status']);

        // SYNC ROLES: Ensure app matches backend's assigned role
        final backendRole = data['role'];
        if (backendRole == 'admin') {
          _role = UserRole.admin;
        } else if (backendRole == 'mentor' || backendRole == 'alumni') {
          _role = UserRole.mentor;
        } else {
          _role = UserRole.student;
        }

        _isDemoMode = false;
        _isAdmin = (_role == UserRole.admin);
        notifyListeners();
        return true;
      } else {
        if (allowDemoFallback && email.isNotEmpty)
          return _fallbackToDemo(email);
        _error = 'Auth failed (${response.statusCode})';
        return false;
      }
    } catch (e) {
      if (allowDemoFallback && email.isNotEmpty) return _fallbackToDemo(email);
      _error = 'Connection failed. Check signaling server status.';
      return false;
    } finally {
      _isLoading = false;
      _forceSetup = false;
      notifyListeners();
    }
  }

  UserStatus _mapStatus(String? status) {
    if (status == null) return UserStatus.incomplete;
    final lowerStatus = status.toLowerCase();
    switch (lowerStatus) {
      case 'verified':
        return UserStatus.verified;
      case 'pending':
        return UserStatus.pending;
      case 'rejected':
        return UserStatus.rejected;
      default:
        return UserStatus.incomplete;
    }
  }

  bool _fallbackToDemo(String email) {
    _isDemoMode = true;
    final lowEmail = email.toLowerCase();
    _role = lowEmail.endsWith('@admin.com')
        ? UserRole.admin
        : (lowEmail.endsWith('@alumni.com')
            ? UserRole.mentor
            : (lowEmail.endsWith('@stud.com') ? UserRole.student : UserRole.student));
    _userId = '${DateTime.now().millisecondsSinceEpoch}';
    _email = email;
    String rawName = email.contains('@') ? email.split('@')[0] : email;
    _userName = rawName
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '')
        .join(' ');

    if (_userName.isEmpty) _userName = 'Demo User';
    _status = UserStatus.incomplete;
    _forceSetup = false; // Default to false for demo logins
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
    // 1. Update local state
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
      _forceSetup = false;
    }
    notifyListeners();

    // 2. Persist to Backend
    if (_userId != null && !_isDemoMode) {
      final module = (_role == UserRole.mentor) ? 'alumni' : 'student';
      final url = getBaseUrl('$module/profile/$_userId');

      try {
        await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'name': _userName,
                'fullName': _fullName,
                'phone': _phoneNumber,
                'branch': _branch,
                'year': _graduationYear,
                'bio': _bio,
                'techField': _techField,
                'company': _company,
                'skills': _skills,
                'socialLinks': {
                  'linkedin': _linkedInUrl,
                  'github': _githubUrl,
                  'portfolio': _portfolioUrl,
                }
              }),
            )
            .timeout(const Duration(seconds: 5));
        dev.log('💾 [AUTH] Profile persisted to backend ($module)');
      } catch (e) {
        dev.log('⚠️ [AUTH] Failed to persist profile: $e');
      }
    }
  }

  Future<void> submitForVerification() async {
    _status = UserStatus.pending;
    notifyListeners();

    if (_userId != null && !_isDemoMode && _role == UserRole.mentor) {
      final url = getBaseUrl('alumni/verify/$_userId');
      try {
        await http.post(Uri.parse(url)).timeout(const Duration(seconds: 5));
        dev.log('🛡️ [AUTH] Verification request submitted to backend');
      } catch (e) {
        dev.log('⚠️ [AUTH] Verification submission failed: $e');
      }
    }

    // Development / Demo Auto-Verification Bypass
    if (_isDemoMode || kDebugMode) {
      dev.log(
          '🧪 [AUTH] Debug/Demo mode detected. Auto-verifying in 5 seconds...');
      Future.delayed(const Duration(seconds: 5), () {
        _status = UserStatus.verified;
        _isAdmin = (_role == UserRole.admin);
        notifyListeners();
        dev.log('✅ [AUTH] Account auto-verified for development');
      });
    }
  }

  Future<void> syncStatusWithServer() async {
    if (_userId == null || _isDemoMode) return;

    final url = getBaseUrl('auth/status/$_userId');
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newStatus = _mapStatus(data['status']);
        if (newStatus != _status) {
          _status = newStatus;
          notifyListeners();
          dev.log('🔄 [AUTH] Status synchronized: $_status');
        }
      }
    } catch (e) {
      dev.log('⚠️ [AUTH] Status sync failed: $e');
    }
  }

  bool get canAccessPremiumFeatures => _status == UserStatus.verified;

  void logout() {
    _userId = null;
    _isDemoMode = false;
    _role = UserRole.mentor;
    _status = UserStatus.incomplete;
    _forceSetup = false;
    notifyListeners();
  }

  void enableSignupMode(String email) {
    _forceSetup = true;
    _status = UserStatus.incomplete;
    _email = email;
    _userId = "TEMP_${DateTime.now().millisecondsSinceEpoch}";
    final lowEmail = email.toLowerCase();
    _role = lowEmail.endsWith('@admin.com')
        ? UserRole.admin
        : (lowEmail.endsWith('@alumin.com')
            ? UserRole.mentor
            : UserRole.student);
    notifyListeners();
  }
}

