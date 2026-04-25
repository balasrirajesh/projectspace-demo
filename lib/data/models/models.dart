// ─── Post (Alumni insights/tips) ─────────────────────────────────────────────
class PostModel {
  final String id;
  final String alumniId;
  final String alumniName;
  final String alumniCompany;
  final String alumniPhotoUrl;
  final String content;
  final String type; // 'advice', 'story', 'confession', 'tip'
  final List<String> tags;
  final int likes;
  final int saves;
  final bool isAnonymous;
  final DateTime postedAt;

  const PostModel({
    required this.id,
    required this.alumniId,
    required this.alumniName,
    required this.alumniCompany,
    required this.alumniPhotoUrl,
    required this.content,
    required this.type,
    required this.tags,
    required this.likes,
    required this.saves,
    required this.isAnonymous,
    required this.postedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      alumniId: json['alumniId'] ?? '',
      alumniName: json['alumniName'] ?? '',
      alumniCompany: json['alumniCompany'] ?? '',
      alumniPhotoUrl: json['alumniPhotoUrl'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'advice',
      tags: List<String>.from(json['tags'] ?? []),
      likes: json['likes'] ?? 0,
      saves: json['saves'] ?? 0,
      isAnonymous: json['isAnonymous'] ?? false,
      postedAt: DateTime.tryParse(json['postedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ─── Q&A Question ─────────────────────────────────────────────────────────────
class QAModel {
  final String id;
  final String question;
  final String askedBy;      // student name
  final String askedById;    // student id
  final DateTime timestamp;
  final int upvotes;
  final List<String> tags;
  final List<QAAnswer> answers;
  final bool isAnswered;

  const QAModel({
    required this.id,
    required this.question,
    required this.askedBy,
    required this.askedById,
    required this.timestamp,
    required this.upvotes,
    required this.tags,
    required this.answers,
    required this.isAnswered,
  });

  factory QAModel.fromJson(Map<String, dynamic> json) {
    return QAModel(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      askedBy: json['askedBy'] ?? '',
      askedById: json['askedById'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      upvotes: json['upvotes'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      answers: (json['answers'] as List? ?? [])
          .map((a) => QAAnswer.fromJson(a))
          .toList(),
      isAnswered: json['isAnswered'] ?? false,
    );
  }
}

// ─── Q&A Answer ───────────────────────────────────────────────────────────────
class QAAnswer {
  final String id;
  final String alumniId;
  final String alumniName;
  final String alumniCompany;
  final String alumniPhotoUrl;
  final String answer;
  final bool isBestAnswer;
  final int upvotes;
  final DateTime answeredAt;

  const QAAnswer({
    required this.id,
    required this.alumniId,
    required this.alumniName,
    required this.alumniCompany,
    required this.alumniPhotoUrl,
    required this.answer,
    this.isBestAnswer = false,
    required this.upvotes,
    required this.answeredAt,
  });

  factory QAAnswer.fromJson(Map<String, dynamic> json) {
    return QAAnswer(
      id: json['id'] ?? '',
      alumniId: json['alumniId'] ?? '',
      alumniName: json['alumniName'] ?? '',
      alumniCompany: json['alumniCompany'] ?? '',
      alumniPhotoUrl: json['alumniPhotoUrl'] ?? '',
      answer: json['answer'] ?? '',
      isBestAnswer: json['isBestAnswer'] ?? false,
      upvotes: json['upvotes'] ?? 0,
      answeredAt: DateTime.tryParse(json['answeredAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ─── Event ────────────────────────────────────────────────────────────────────
class EventModel {
  final String id;
  final String title;
  final String description;
  final String hostAlumniName;
  final String hostCompany;
  final DateTime eventDate;
  final String type; // 'webinar', 'workshop', 'career_talk', 'mockinterview'
  final int registeredCount;
  final bool isRsvped;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.hostAlumniName,
    required this.hostCompany,
    required this.eventDate,
    required this.type,
    required this.registeredCount,
    required this.isRsvped,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      hostAlumniName: json['hostAlumniName'] ?? '',
      hostCompany: json['hostCompany'] ?? '',
      eventDate: DateTime.tryParse(json['eventDate'] ?? '') ?? DateTime.now(),
      type: json['type'] ?? 'webinar',
      registeredCount: json['registeredCount'] ?? 0,
      isRsvped: json['isRsvped'] ?? false,
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────
class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isEarned;
  final String category;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isEarned,
    required this.category,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏅',
      isEarned: json['isEarned'] ?? false,
      category: json['category'] ?? '',
    );
  }
}
