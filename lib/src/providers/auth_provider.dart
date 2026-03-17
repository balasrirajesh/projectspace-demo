import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String _userName = "Alex";
  String _techField = "Flutter Developer";
  String _company = "Google";
  String _yoe = "5+";

  String get userName => _userName;
  String get techField => _techField;
  String get company => _company;
  String get yoe => _yoe;

  void updateProfile({String? name, String? field, String? company, String? yoe}) {
    if (name != null) _userName = name;
    if (field != null) _techField = field;
    if (company != null) _company = company;
    if (yoe != null) _yoe = yoe;
    notifyListeners();
  }
}
