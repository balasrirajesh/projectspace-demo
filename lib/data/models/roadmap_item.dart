class RoadmapItem {
  final String title;
  final String description;
  final String duration;
  final String emoji;
  final List<String> resources;
  final bool isComplete;

  RoadmapItem({
    required this.title,
    required this.description,
    required this.duration,
    required this.emoji,
    required this.resources,
    this.isComplete = false,
  });

  factory RoadmapItem.fromJson(Map<String, dynamic> json) {
    return RoadmapItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      emoji: json['emoji'] ?? '📍',
      resources: List<String>.from(json['resources'] ?? []),
      isComplete: json['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'duration': duration,
      'emoji': emoji,
      'resources': resources,
      'isComplete': isComplete,
    };
  }
}
