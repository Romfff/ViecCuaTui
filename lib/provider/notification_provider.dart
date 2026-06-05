import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  final Map<String, String> _cvDecisions = {};

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _cvDecisions.clear();
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      final old = _notifications[i];
      _notifications[i] = NotificationModel(
        id: old.id,
        title: old.title,
        subtitle: old.subtitle,
        createdAt: old.createdAt,
        isRead: true,
        recipientRole: old.recipientRole,
        applicantName: old.applicantName,
        applicantRole: old.applicantRole,
        cvFileName: old.cvFileName,
        cvBytes: old.cvBytes,
        cvBody: old.cvBody,
        applicantId: old.applicantId,
        jobId: old.jobId,
      );
    }
    notifyListeners();
  }

  void setCvDecision(String cvKey, String decision) {
    _cvDecisions[cvKey] = decision;
    notifyListeners();
  }

  String? getCvDecision(String cvKey) => _cvDecisions[cvKey];
}
