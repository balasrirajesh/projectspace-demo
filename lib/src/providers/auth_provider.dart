import 'package:flutter/material.dart';

/// Manages the authentication state and user profile information.
/// 
/// This provider holds details about the current user and provides methods
/// to update their profile settings.
class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  /// Indicates if an authentication-related operation is currently in progress.
  bool get isLoading => _isLoading;

  /// The most recent error message, if any.
  String? get error => _error;

  String _userName = "Alex";
  String _techField = "Flutter Developer";
  String _company = "Google";
  String _yoe = "5+";

  /// The current user's name.
  String get userName => _userName;

  /// The current user's professional field.
  String get techField => _techField;

  /// The company where the user currently works.
  String get company => _company;

  /// The number of years of experience the user has.
  String get yoe => _yoe;

  /// Updates the user's profile information and notifies listeners.
  /// 
  /// Parameters are optional; only non-null values will be updated.
  void updateProfile({String? name, String? field, String? company, String? yoe}) {
    if (name != null) _userName = name;
    if (field != null) _techField = field;
    if (company != null) _company = company;
    if (yoe != null) _yoe = yoe;
    notifyListeners();
  }
}

