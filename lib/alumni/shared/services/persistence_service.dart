import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service that handles persistent data storage.
///
/// This service uses the `shared_preferences` package to store and retrieve
/// JSON-encoded data across app restarts.
class PersistenceService {
  static final PersistenceService _instance = PersistenceService._internal();
  factory PersistenceService() => _instance;
  PersistenceService._internal();

  static const String keyMentorship = 'mentorship_data';
  static const String keyChat = 'chat_data';
  static const String keyAuth = 'auth_data';

  /// Saves the given [data] to local storage under the specified [key].
  ///
  /// The data is JSON-encoded before being stored as a string.
  Future<void> saveData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  /// Retrieves and decodes JSON data from local storage for the specified [key].
  ///
  /// Returns `null` if no data is found for the key.
  Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(key);
    if (data == null) return null;
    return jsonDecode(data);
  }

  /// Clears all stored data from local storage.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
