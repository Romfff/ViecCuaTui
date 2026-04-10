class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.isRead = false,
  });
}
