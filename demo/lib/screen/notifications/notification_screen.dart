import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../provider/notification_provider.dart';

const _kNavy = Color(0xFF0D1B4B);
const _kAccent = Color(0xFF43E8D8);
const _kTextSecondary = Color(0xFF8E8E93);

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationProvider>().notifications;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _kNavy,
        elevation: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => context.read<NotificationProvider>().clearAll(),
              child: const Text(
                'XÓA TẤT CẢ',
                style: TextStyle(color: _kAccent, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: notifications.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Bạn chưa có thông báo nào.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _kAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: _kAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kNavy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _kTextSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _formatRelativeTime(item.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatRelativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    return '${difference.inDays} ngày trước';
  }
}
