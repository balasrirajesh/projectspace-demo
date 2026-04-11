/// Defines the possible states of a mentorship request or session.
enum MentorshipStatus { pending, accepted, rejected, ended }

/// Represents a student (mentee) in the system.
class Student {
  /// Unique identifier for the student.
  final String id;

  /// The full name of the student.
  final String name;

  /// The academic department/branch of the student.
  final String branch;

  /// The current academic year of the student (e.g., "3rd Year").
  final String year;

  /// A list of skills or areas of interest the student has.
  final List<String> skills;

  Student({
    required this.id,
    required this.name,
    required this.branch,
    required this.year,
    required this.skills,
  });

  /// Converts the [Student] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'branch': branch,
    'year': year,
    'skills': skills,
  };

  /// Creates a [Student] instance from a JSON map.
  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    branch: json['branch'] ?? '',
    year: json['year'] ?? '',
    skills: List<String>.from(json['skills'] ?? []),
  );
}

/// Represents a formal request for mentorship from a student to a mentor.
class MentorshipRequest {
  /// Unique identifier for the request.
  final String id;

  /// The student who is requesting mentorship.
  final Student student;

  /// The reason or motivation for seeking mentorship.
  final String reason;

  /// Specific topics or areas the student wants help with.
  final List<String> topics;

  /// Optional preferred schedule or time slots for mentorship.
  final String? preferredSchedule;

  /// Current status of the request (defaults to [MentorshipStatus.pending]).
  final MentorshipStatus status;

  /// The timestamp when the request was created.
  final DateTime createdAt;

  MentorshipRequest({
    required this.id,
    required this.student,
    required this.reason,
    required this.topics,
    this.preferredSchedule,
    this.status = MentorshipStatus.pending,
    required this.createdAt,
  });

  /// Returns a new instance of [MentorshipRequest] with updated fields.
  MentorshipRequest copyWith({
    MentorshipStatus? status,
  }) {
    return MentorshipRequest(
      id: id,
      student: student,
      reason: reason,
      topics: topics,
      preferredSchedule: preferredSchedule,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  /// Converts the [MentorshipRequest] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'student': student.toJson(),
    'reason': reason,
    'topics': topics,
    'preferredSchedule': preferredSchedule,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Creates a [MentorshipRequest] instance from a JSON map.
  factory MentorshipRequest.fromJson(Map<String, dynamic> json) => MentorshipRequest(
    id: json['id'],
    student: Student.fromJson(json['student']),
    reason: json['reason'],
    topics: List<String>.from(json['topics']),
    preferredSchedule: json['preferredSchedule'],
    status: MentorshipStatus.values.firstWhere((e) => e.name == json['status']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

