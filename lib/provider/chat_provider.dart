import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatSession {
  final String id;
  final String jobId;
  final String jobTitle;
  final String jobCompany;
  final String jobSeekerId;
  final String jobSeekerName;
  final String recruiterId;
  final String recruiterName;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const ChatSession({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.jobCompany,
    required this.jobSeekerId,
    required this.jobSeekerName,
    required this.recruiterId,
    required this.recruiterName,
    required this.lastMessage,
    this.lastMessageAt,
    required this.createdAt,
  });

  // Backward compatibility with mock properties
  String get name => recruiterName;
  String get description => "$jobTitle - $jobCompany";
  bool get isRecruiter => false;

  factory ChatSession.fromMap(String id, Map<String, dynamic> data) {
    DateTime? lastMsgAt;
    if (data['lastMessageAt'] != null) {
      if (data['lastMessageAt'] is Timestamp) {
        lastMsgAt = (data['lastMessageAt'] as Timestamp).toDate();
      } else if (data['lastMessageAt'] is String) {
        lastMsgAt = DateTime.tryParse(data['lastMessageAt']);
      }
    }

    DateTime created = DateTime.now();
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        created = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        created = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
      }
    }

    return ChatSession(
      id: id,
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      jobCompany: data['jobCompany'] ?? '',
      jobSeekerId: data['jobSeekerId'] ?? '',
      jobSeekerName: data['jobSeekerName'] ?? '',
      recruiterId: data['recruiterId'] ?? '',
      recruiterName: data['recruiterName'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: lastMsgAt,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobCompany': jobCompany,
      'jobSeekerId': jobSeekerId,
      'jobSeekerName': jobSeekerName,
      'recruiterId': recruiterId,
      'recruiterName': recruiterName,
      'participants': [jobSeekerId, recruiterId],
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : FieldValue.serverTimestamp(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String otherUserId(String currentUserId) {
    return currentUserId == jobSeekerId ? recruiterId : jobSeekerId;
  }

  String otherName(String currentUserId) {
    return currentUserId == jobSeekerId ? recruiterName : jobSeekerName;
  }

  String descriptionFor(String currentUserId) {
    if (currentUserId == jobSeekerId) {
      return "$jobTitle - $jobCompany";
    } else {
      return "Ứng tuyển vị trí $jobTitle";
    }
  }

  String otherRole(String currentUserId) {
    return currentUserId == jobSeekerId ? 'job_poster' : 'job_seeker';
  }
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

  factory ChatMessage.fromMap(String id, Map<String, dynamic> data) {
    DateTime created = DateTime.now();
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        created = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        created = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
      }
    }
    return ChatMessage(
      id: id,
      sessionId: data['sessionId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? '',
      text: data['text'] ?? '',
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class ChatProvider extends ChangeNotifier {
  final Map<String, ChatSession> _sessionsCache = {};

  ChatSession? getSession(String id) {
    return _sessionsCache[id];
  }

  // Stream active chat sessions for the user (only ones with messages/creation within 3 days)
  Stream<List<ChatSession>> streamSessions(String userId) {
    final cutoff = DateTime.now().subtract(const Duration(days: 3));

    // Try to physically clean up old sessions/messages from database in background (safely ignored if denied)
    _deleteOldMessagesAndSessions();

    return FirebaseFirestore.instance
        .collection('chat')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ChatSession.fromMap(doc.id, doc.data()))
              .where((s) {
                final time = s.lastMessageAt ?? s.createdAt;
                return time.isAfter(cutoff);
              })
              .toList();

          // Cache sessions for quick synchronous lookups
          for (var session in list) {
            _sessionsCache[session.id] = session;
          }

          // Sort by lastMessageAt descending (nulls last)
          list.sort((a, b) {
            final timeA = a.lastMessageAt ?? a.createdAt;
            final timeB = b.lastMessageAt ?? b.createdAt;
            return timeB.compareTo(timeA);
          });
          return list;
        });
  }

  // Stream messages for a chat session (only ones within 3 days)
  Stream<List<ChatMessage>> streamMessages(String sessionId) {
    // Try to physically clean up old messages in this session in background (safely ignored if denied)
    _deleteOldMessagesInSession(sessionId);

    final cutoff = DateTime.now().subtract(const Duration(days: 3));
    return FirebaseFirestore.instance
        .collection('chat')
        .doc(sessionId)
        .collection('messages')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // Send a message
  Future<void> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String text,
    String? contactId,
    String? contactName,
    String? contactRole,
    String? contactSubtitle,
    String? jobId,
    String? jobTitle,
    String? jobCompany,
  }) async {
    final now = DateTime.now();
    final messageRef = FirebaseFirestore.instance
        .collection('chat')
        .doc(sessionId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: messageRef.id,
      sessionId: sessionId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      text: text,
      createdAt: now,
    );

    // Save message
    await messageRef.set(message.toMap());

    // Update or create session
    final sessionRef = FirebaseFirestore.instance.collection('chat').doc(sessionId);
    final sessionDoc = await sessionRef.get();

    if (!sessionDoc.exists) {
      final jobSeekerId = senderRole == 'job_seeker' ? senderId : (contactId ?? '');
      final jobSeekerName = senderRole == 'job_seeker' ? senderName : (contactName ?? '');
      final recruiterId = senderRole == 'job_poster' ? senderId : (contactId ?? '');
      final recruiterName = senderRole == 'job_poster' ? senderName : (contactName ?? '');

      final session = ChatSession(
        id: sessionId,
        jobId: jobId ?? '',
        jobTitle: jobTitle ?? contactSubtitle ?? '',
        jobCompany: jobCompany ?? '',
        jobSeekerId: jobSeekerId,
        jobSeekerName: jobSeekerName,
        recruiterId: recruiterId,
        recruiterName: recruiterName,
        lastMessage: text,
        lastMessageAt: now,
        createdAt: now,
      );

      await sessionRef.set(session.toMap());
      _sessionsCache[sessionId] = session;
    } else {
      await sessionRef.update({
        'lastMessage': text,
        'lastMessageAt': Timestamp.fromDate(now),
      });
    }

    notifyListeners();
  }

  // Asynchronous cleanup of old sessions/messages from database
  void _deleteOldMessagesAndSessions() {
    final cutoff = DateTime.now().subtract(const Duration(days: 3));
    final firestore = FirebaseFirestore.instance;

    firestore
        .collection('chat')
        .where('lastMessageAt', isLessThan: Timestamp.fromDate(cutoff))
        .get()
        .then((sessionSnapshot) async {
          for (var doc in sessionSnapshot.docs) {
            try {
              // Delete messages subcollection
              final messagesSnapshot = await doc.reference.collection('messages').get();
              final batch = firestore.batch();
              for (var msgDoc in messagesSnapshot.docs) {
                batch.delete(msgDoc.reference);
              }
              // Delete session
              batch.delete(doc.reference);
              await batch.commit();
              _sessionsCache.remove(doc.id);
            } catch (e) {
              // Handle silent cleanup permission/network failures
              print('Background cleanup info: Session delete skipped or not permitted ($e)');
            }
          }
        }).catchError((e) {
          print('Background cleanup info: Session query skipped or not permitted ($e)');
        });
  }

  // Asynchronous cleanup of old messages in a specific session
  void _deleteOldMessagesInSession(String sessionId) {
    final cutoff = DateTime.now().subtract(const Duration(days: 3));
    FirebaseFirestore.instance
        .collection('chat')
        .doc(sessionId)
        .collection('messages')
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoff))
        .get()
        .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final batch = FirebaseFirestore.instance.batch();
            for (var doc in snapshot.docs) {
              batch.delete(doc.reference);
            }
            batch.commit().catchError((e) {
              print('Background cleanup info: Messages batch delete skipped or not permitted ($e)');
            });
          }
        }).catchError((e) {
          print('Background cleanup info: Messages query skipped or not permitted ($e)');
        });
  }
}
