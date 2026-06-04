import 'package:flutter/material.dart';

class ChatSession {
  final String id;
  final String name;
  final String role;
  final String description;
  final bool isRecruiter;

  const ChatSession({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
    required this.isRecruiter,
  });
}

class ChatMessage {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatSession> _sessions = const [
    ChatSession(
      id: 'recruiter_abcd',
      name: 'Công ty ABC',
      role: 'Nhà tuyển dụng',
      description: 'Tuyển Mobile Dev, Hà Nội',
      isRecruiter: true,
    ),
    ChatSession(
      id: 'recruiter_xyz',
      name: 'Công ty XYZ',
      role: 'Nhà tuyển dụng',
      description: 'Tuyển Product Manager',
      isRecruiter: true,
    ),
    ChatSession(
      id: 'candidate_alex',
      name: 'Alexandra Chen',
      role: 'Ứng viên',
      description: 'Senior UI Designer',
      isRecruiter: false,
    ),
    ChatSession(
      id: 'candidate_julian',
      name: 'Julian Blackwood',
      role: 'Ứng viên',
      description: 'Product Manager',
      isRecruiter: false,
    ),
  ];

  final Map<String, List<ChatMessage>> _messages = {};

  ChatProvider() {
    _messages['recruiter_abcd'] = [
      ChatMessage(
        id: 'm1',
        sessionId: 'recruiter_abcd',
        senderId: 'recruiter_abcd',
        senderName: 'Công ty ABC',
        senderRole: 'job_poster',
        text: 'Xin chào, bạn đang quan tâm vị trí Mobile Dev tại công ty chúng tôi đúng không?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      ChatMessage(
        id: 'm2',
        sessionId: 'recruiter_abcd',
        senderId: 'candidate_user',
        senderName: 'Bạn',
        senderRole: 'job_seeker',
        text: 'Vâng, tôi muốn trao đổi thêm về yêu cầu công việc.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ];
    _messages['recruiter_xyz'] = [
      ChatMessage(
        id: 'm3',
        sessionId: 'recruiter_xyz',
        senderId: 'recruiter_xyz',
        senderName: 'Công ty XYZ',
        senderRole: 'job_poster',
        text: 'Chúng tôi cần ứng viên có kinh nghiệm sản phẩm tối thiểu 5 năm.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      ),
    ];
    _messages['candidate_alex'] = [
      ChatMessage(
        id: 'm4',
        sessionId: 'candidate_alex',
        senderId: 'candidate_alex',
        senderName: 'Alexandra Chen',
        senderRole: 'job_seeker',
        text: 'Xin chào, mình đã nộp hồ sơ và muốn hỏi thêm về quy trình phỏng vấn.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
      ),
    ];
    _messages['candidate_julian'] = [
      ChatMessage(
        id: 'm5',
        sessionId: 'candidate_julian',
        senderId: 'candidate_julian',
        senderName: 'Julian Blackwood',
        senderRole: 'job_seeker',
        text: 'Tôi đã upload CV rồi, mong công ty xem xét giúp.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 20)),
      ),
    ];
  }

  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  List<ChatSession> sessionsForRole(String? role) {
    final isRecruiter = role == 'job_poster';
    return _sessions.where((session) => session.isRecruiter != isRecruiter).toList();
  }

  ChatSession? getSession(String id) {
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ChatMessage> getMessages(String sessionId) {
    return List.unmodifiable(_messages[sessionId] ?? []);
  }

  void sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
  }) {
    final messages = _messages.putIfAbsent(sessionId, () => []);
    messages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: sessionId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
