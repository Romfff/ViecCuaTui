import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../provider/chat_provider.dart';
import '../home/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chatProv = context.read<ChatProvider>();
    final userId = auth.user?.uid ?? '';
    final title = auth.role == 'job_poster'
        ? 'Danh sách ứng viên'
        : 'Danh sách nhà tuyển dụng';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<ChatSession>>(
        stream: chatProv.streamSessions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Không tải được danh sách chat: ${snapshot.error}'),
            );
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(child: Text('Chưa có cuộc trò chuyện nào.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final session = sessions[index];
              final contactId = session.otherUserId(userId);
              final contactName = session.otherName(userId);
              final contactSubtitle = session.descriptionFor(userId);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Text(
                    contactName.isNotEmpty ? contactName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  contactName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  session.lastMessage.isNotEmpty
                      ? session.lastMessage
                      : contactSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        sessionId: session.id,
                        contactId: contactId,
                        contactName: contactName,
                        contactRole: session.otherRole(userId),
                        contactSubtitle: contactSubtitle,
                        jobId: session.jobId,
                        jobTitle: session.jobTitle,
                        jobCompany: session.jobCompany,
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: sessions.length,
          );
        },
      ),
    );
  }
}
