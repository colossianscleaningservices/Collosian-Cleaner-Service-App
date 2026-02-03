/// Represents a single chat message (text, optional image, metadata).
/// Backend/real-time: map from API or WebSocket payload to this model.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isOutgoing,
    required this.timestamp,
    this.imageUrl,
    this.isRead = false,
    this.replyToId,
    this.replyToPreview,
  });

  final String id;
  final String text;
  final bool isOutgoing;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isRead;
  final String? replyToId;
  final String? replyToPreview;

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isOutgoing,
    DateTime? timestamp,
    String? imageUrl,
    bool? isRead,
    String? replyToId,
    String? replyToPreview,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      replyToId: replyToId ?? this.replyToId,
      replyToPreview: replyToPreview ?? this.replyToPreview,
    );
  }
}
