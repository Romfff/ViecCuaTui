import 'dart:typed_data';

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final bool isRead;
  final String? recipientRole;
  final String? applicantName;
  final String? applicantRole;
  final String? cvFileName;
  final Uint8List? cvBytes;
  final String? cvBody;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    this.isRead = false,
    this.recipientRole,
    this.applicantName,
    this.applicantRole,
    this.cvFileName,
    this.cvBytes,
    this.cvBody,
  });
}
