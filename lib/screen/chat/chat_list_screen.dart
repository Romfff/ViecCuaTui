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
    final chatProv = context.watch<ChatProvider>();
    final sessions = chatProv.sessionsForRole(auth.role);
    final title = auth.role == 'job_poster' ? 'Danh sách ứng viên' : 'Danh sách nhà tuyển dụng';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final session = sessions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Text(
                session.name.isNotEmpty ? session.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(session.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(session.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    sessionId: session.id,
                    contactName: session.name,
                    contactSubtitle: session.description,
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemCount: sessions.length,
      ),
    );
  }
}
