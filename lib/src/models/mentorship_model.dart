enum MentorshipStatus { pending, accepted, rejected, ended }

class Student {
  final String id;
  final String name;
  final String branch;
  final String year;
  final List<String> skills;

  Student({
    required this.id,
    required this.name,
    required this.branch,
    required this.year,
    required this.skills,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'branch': branch,
    'year': year,
    'skills': skills,
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    branch: json['branch'] ?? '',
    year: json['year'] ?? '',
    skills: List<String>.from(json['skills'] ?? []),
  );
}

class MentorshipRequest {
  final String id;
  final Student student;
  final String reason;
  final List<String> topics;
  final String? preferredSchedule;
  final MentorshipStatus status;
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'student': student.toJson(),
    'reason': reason,
    'topics': topics,
    'preferredSchedule': preferredSchedule,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };

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
