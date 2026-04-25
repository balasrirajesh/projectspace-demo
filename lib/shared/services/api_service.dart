import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/data/models/alumni_model.dart';
import 'package:graduway/data/models/student_model.dart';
import 'package:graduway/data/models/models.dart';
import 'package:flutter/foundation.dart';

/// Unified service for fetching general platform data from the backend.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get _baseUrl => AuthProvider.getBaseUrl('');

  /// Fetches the alumni directory
  Future<List<AlumniModel>> fetchAlumni() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}alumni'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AlumniModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching alumni: $e');
    }
    return [];
  }

  /// Fetches the student directory
  Future<List<StudentModel>> fetchStudents() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}students'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StudentModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching students: $e');
    }
    return [];
  }

  /// Fetches the Q&A threads
  Future<List<QAModel>> fetchQA() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}qa'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => QAModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching QA: $e');
    }
    return [];
  }

  /// Posts a new question
  Future<bool> postQuestion(String question, String userId, String userName) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}qa'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'question': question,
          'askedById': userId,
          'askedBy': userName,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error posting question: $e');
      return false;
    }
  }

  /// Fetches placement stories
  Future<List<dynamic>> fetchPlacementStories() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}placement'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching placement stories: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchSkillPackages() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}skill-packages'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching skill packages: $e');
    }
    return {};
  }

  Future<List<dynamic>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}events'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
    }
    return [];
  }

  Future<List<dynamic>> fetchBadges() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}badges'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching badges: $e');
    }
    return [];
  }

  Future<bool> postAnswer(String questionId, Map<String, dynamic> answer) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}qa/$questionId/answers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(answer),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error posting answer: $e');
      return false;
    }
  }
}
