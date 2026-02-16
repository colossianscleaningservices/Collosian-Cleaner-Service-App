enum NotificationType { jobAssigned, jobUpdate, payment, message, reminder }

class NotificationData {
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationData({
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}
