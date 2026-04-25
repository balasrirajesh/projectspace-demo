class AlumniModel {
  final String id;
  final String name;
  final String batch;
  final String branch;
  final String company;
  final String role;
  final String location;
  final double package; // LPA
  final List<String> skills;
  final String photoUrl;
  final String advice;
  final String story;
  final String linkedIn;
  final bool isVerified;
  final int menteeCount;
  final double rating;
  final String anonConfession;
  final List<String> interviewRounds;
  final String targetRole; // FAANG, Product, Service, Core, Higher Studies
  final String email;
  final int yearsOfExp;

  const AlumniModel({
    required this.id,
    required this.name,
    this.batch = '',
    this.branch = '',
    this.company = '',
    this.role = '',
    this.location = '',
    this.package = 0.0,
    this.skills = const [],
    this.photoUrl = '',
    this.advice = '',
    this.story = '',
    this.linkedIn = '',
    this.isVerified = false,
    this.menteeCount = 0,
    this.rating = 0.0,
    this.anonConfession = '',
    this.interviewRounds = const [],
    this.targetRole = '',
    this.email = '',
    this.yearsOfExp = 0,
  });

  factory AlumniModel.fromJson(Map<String, dynamic> json) {
    return AlumniModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      batch: json['batch'] ?? '',
      branch: json['branch'] ?? '',
      company: json['company'] ?? '',
      role: json['role'] ?? '',
      location: json['location'] ?? '',
      package: (json['package'] ?? 0.0).toDouble(),
      skills: List<String>.from(json['skills'] ?? []),
      photoUrl: json['photoUrl'] ?? '',
      advice: json['advice'] ?? '',
      story: json['story'] ?? '',
      linkedIn: json['linkedIn'] ?? '',
      isVerified: json['isVerified'] ?? false,
      menteeCount: json['menteeCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      anonConfession: json['anonConfession'] ?? '',
      interviewRounds: List<String>.from(json['interviewRounds'] ?? []),
      targetRole: json['targetRole'] ?? '',
      email: json['email'] ?? '',
      yearsOfExp: json['yearsOfExp'] ?? 0,
    );
  }
}
