/// Represents a single message in a chat session.
class ChatMessage {
  /// Unique identifier for the message.
  final String id;

  /// The ID of the user who sent the message.
  final String senderId;

  /// The content of the message.
  final String text;

  /// The time when the message was sent.
  final DateTime timestamp;

  /// Whether the message has been seen by the recipient.
  final bool isSeen;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isSeen = false,
  });

  /// Converts the [ChatMessage] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'isSeen': isSeen,
      };

  /// Creates a [ChatMessage] instance from a JSON map.
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        senderId: json['senderId'],
        text: json['text'],
        timestamp: DateTime.parse(json['timestamp']),
        isSeen: json['isSeen'] ?? false,
      );
}

/// Represents a chat conversation between a mentor and a mentee.
class ChatSession {
  /// Unique identifier for the chat session.
  final String chatId;

  /// The ID of the mentor involved in the session.
  final String mentorId;

  /// The ID of the mentee (student) involved in the session.
  final String menteeId;

  /// The list of messages in this chat session.
  final List<ChatMessage> messages;

  ChatSession({
    required this.chatId,
    required this.mentorId,
    required this.menteeId,
    required this.messages,
  });
}
