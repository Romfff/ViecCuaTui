import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = NotificationModel(
        id: _notifications[i].id,
        title: _notifications[i].title,
        subtitle: _notifications[i].subtitle,
        createdAt: _notifications[i].createdAt,
        isRead: true,
      );
    }
    notifyListeners();
  }
}
