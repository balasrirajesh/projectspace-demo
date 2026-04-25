class StudentModel {
  final String id;
  final String name;
  final String email;
  final String branch;
  final int year; // 1-4
  final String targetCareer; // FAANG, Product, Service, Core, Higher Studies, Startup
  final List<String> skills;
  final int careerScore; // 0-100
  final List<String> earnedBadges;
  final int questionsAsked;
  final int mentorSessionsAttended;
  final String photoUrl;
  final String rollNumber;

  const StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.branch,
    required this.year,
    this.targetCareer = '',
    this.skills = const [],
    this.careerScore = 0,
    this.earnedBadges = const [],
    this.questionsAsked = 0,
    this.mentorSessionsAttended = 0,
    this.photoUrl = '',
    this.rollNumber = '',
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      branch: json['branch'] ?? '',
      year: json['year'] ?? 1,
      targetCareer: json['targetCareer'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      careerScore: json['careerScore'] ?? 0,
      earnedBadges: List<String>.from(json['earnedBadges'] ?? []),
      questionsAsked: json['questionsAsked'] ?? 0,
      mentorSessionsAttended: json['mentorSessionsAttended'] ?? 0,
      photoUrl: json['photoUrl'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
    );
  }
}
