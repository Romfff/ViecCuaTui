import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/chat_provider.dart';
import '../../provider/notification_provider.dart';
import '../../models/notification_model.dart';

const _kBg = Color(0xFFF8F9FB);
const _kNavy = Color(0xFF0D1B4B);
const _kAccent = Color(0xFF43E8D8);

class ChatScreen extends StatefulWidget {
  final String sessionId;
  final String contactName;
  final String contactSubtitle;

  const ChatScreen({
    super.key,
    required this.sessionId,
    required this.contactName,
    required this.contactSubtitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final chatProv = context.read<ChatProvider>();
    final senderId = auth.user?.uid ?? 'guest';
    final senderName = auth.fullName?.trim().isNotEmpty == true ? auth.fullName! : 'Bạn';
    final senderRole = auth.role ?? 'job_seeker';
    final contact = chatProv.getSession(widget.sessionId);

    chatProv.sendMessage(
      sessionId: widget.sessionId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
    );

    context.read<NotificationProvider>().addNotification(
      NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Tin nhắn mới từ $senderName',
        subtitle: '$senderName đã gửi tin nhắn tới ${widget.contactName}.',
        createdAt: DateTime.now(),
        recipientRole: senderRole == 'job_seeker' ? 'job_poster' : 'job_seeker',
      ),
    );

    _messageController.clear();

    if (senderRole != 'job_poster' && contact != null) {
      final chatName = contact.name;
      Future.delayed(const Duration(milliseconds: 800), () {
        chatProv.sendMessage(
          sessionId: widget.sessionId,
          senderId: widget.sessionId,
          senderName: chatName,
          senderRole: 'job_poster',
          text: 'Cảm ơn đã liên hệ! Chúng tôi đã nhận được tin nhắn của bạn và sẽ phản hồi sớm.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chatProv = context.watch<ChatProvider>();
    final messages = chatProv.getMessages(widget.sessionId);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kNavy),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contactName, style: const TextStyle(color: _kNavy, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(widget.contactSubtitle, style: const TextStyle(color: _kAccent, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Công ty',
                  style: TextStyle(
                    color: _kAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.contactName,
                  style: const TextStyle(
                    color: _kNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.contactSubtitle,
                  style: const TextStyle(
                    color: _kAccent,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMine = auth.user != null && message.senderId == auth.user!.uid;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMine ? _kAccent : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMine)
                            Text(
                              message.senderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _kNavy,
                                fontSize: 12,
                              ),
                            ),
                          if (!isMine) const SizedBox(height: 4),
                          Text(
                            message.text,
                            style: TextStyle(
                              color: isMine ? _kNavy : _kNavy,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      fillColor: _kBg,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.send, color: _kNavy, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
