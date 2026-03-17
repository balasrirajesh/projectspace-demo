class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isSeen;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isSeen = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'isSeen': isSeen,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    senderId: json['senderId'],
    text: json['text'],
    timestamp: DateTime.parse(json['timestamp']),
    isSeen: json['isSeen'] ?? false,
  );
}

class ChatSession {
  final String chatId;
  final String mentorId;
  final String menteeId;
  final List<ChatMessage> messages;

  ChatSession({
    required this.chatId,
    required this.mentorId,
    required this.menteeId,
    required this.messages,
  });
}
