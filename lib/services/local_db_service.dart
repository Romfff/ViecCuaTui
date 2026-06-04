import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/interview_model.dart';

class LocalDbService {
  static const String _interviewBoxName = 'interviews';
  
  static final LocalDbService _instance = LocalDbService._privateConstructor();
  
  LocalDbService._privateConstructor();
  
  static LocalDbService get instance => _instance;
  
  late Box<Map> _interviewBox;
  bool _isInitialized = false;
  
  // Initialize Hive
  Future<void> init() async {
    try {
      if (_isInitialized) return;
      
      // Register adapter for InterviewModel type
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(InterviewModelAdapter());
      }
      
      // Open box for interviews
      _interviewBox = await Hive.openBox<Map>(_interviewBoxName);
      _isInitialized = true;
      
      print('✓ Hive database initialized successfully');
    } catch (e) {
      print('❌ Error initializing Hive: $e');
      rethrow;
    }
  }
  
  // Save interview
  Future<void> saveInterview(InterviewModel interview) async {
    try {
      final data = {
        'id': interview.id,
        'recruiterId': interview.recruiterId,
        'candidateId': interview.candidateId,
        'candidateName': interview.candidateName,
        'candidateRole': interview.candidateRole,
        'interviewTime': interview.interviewTime,
        'meetLink': interview.meetLink ?? '',
        'status': interview.status,
        'interviewType': interview.interviewType,
        'officeAddress': interview.officeAddress ?? '',
        'applicationId': interview.applicationId ?? '',
        'createdAt': interview.createdAt.toIso8601String(),
        'startedAt': interview.startedAt?.toIso8601String() ?? '',
        'endedAt': interview.endedAt?.toIso8601String() ?? '',
      };
      
      await _interviewBox.put(interview.id, data);
      print('✓ Interview saved to Hive: ${interview.id}');
    } catch (e) {
      print('❌ Error saving interview to Hive: $e');
      rethrow;
    }
  }
  
  // Get interview by ID
  Future<InterviewModel?> getInterviewById(String id) async {
    try {
      final data = _interviewBox.get(id);
      if (data == null) return null;
      
      return _mapToInterview(id, data);
    } catch (e) {
      print('❌ Error getting interview from Hive: $e');
      return null;
    }
  }
  
  // Get recruiter interviews
  Future<List<InterviewModel>> getRecruiterInterviews(String recruiterId) async {
    try {
      final interviews = <InterviewModel>[];
      
      for (var entry in _interviewBox.toMap().entries) {
        final data = entry.value;
        if (data['recruiterId'] == recruiterId) {
          interviews.add(_mapToInterview(entry.key, data));
        }
      }
      
      // Sort by createdAt descending
      interviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('✓ Loaded ${interviews.length} recruiter interviews from Hive');
      return interviews;
    } catch (e) {
      print('❌ Error getting recruiter interviews from Hive: $e');
      return [];
    }
  }
  
  // Get candidate interviews
  Future<List<InterviewModel>> getCandidateInterviews(String candidateId) async {
    try {
      final interviews = <InterviewModel>[];
      
      for (var entry in _interviewBox.toMap().entries) {
        final data = entry.value;
        if (data['candidateId'] == candidateId) {
          interviews.add(_mapToInterview(entry.key, data));
        }
      }
      
      // Sort by createdAt descending
      interviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('✓ Loaded ${interviews.length} candidate interviews from Hive');
      return interviews;
    } catch (e) {
      print('❌ Error getting candidate interviews from Hive: $e');
      return [];
    }
  }
  
  // Get all interviews
  Future<List<InterviewModel>> getAllInterviews() async {
    try {
      final interviews = <InterviewModel>[];
      
      for (var entry in _interviewBox.toMap().entries) {
        interviews.add(_mapToInterview(entry.key, entry.value));
      }
      
      print('✓ Loaded ${interviews.length} total interviews from Hive');
      return interviews;
    } catch (e) {
      print('❌ Error getting all interviews from Hive: $e');
      return [];
    }
  }
  
  // Update interview
  Future<void> updateInterview(InterviewModel interview) async {
    try {
      final data = {
        'id': interview.id,
        'recruiterId': interview.recruiterId,
        'candidateId': interview.candidateId,
        'candidateName': interview.candidateName,
        'candidateRole': interview.candidateRole,
        'interviewTime': interview.interviewTime,
        'meetLink': interview.meetLink ?? '',
        'status': interview.status,
        'interviewType': interview.interviewType,
        'officeAddress': interview.officeAddress ?? '',
        'applicationId': interview.applicationId ?? '',
        'createdAt': interview.createdAt.toIso8601String(),
        'startedAt': interview.startedAt?.toIso8601String() ?? '',
        'endedAt': interview.endedAt?.toIso8601String() ?? '',
      };
      
      await _interviewBox.put(interview.id, data);
      print('✓ Interview updated in Hive: ${interview.id}');
    } catch (e) {
      print('❌ Error updating interview in Hive: $e');
      rethrow;
    }
  }
  
  // Delete interview
  Future<void> deleteInterview(String interviewId) async {
    try {
      await _interviewBox.delete(interviewId);
      print('✓ Interview deleted from Hive: $interviewId');
    } catch (e) {
      print('❌ Error deleting interview from Hive: $e');
      rethrow;
    }
  }
  
  // Clear all interviews
  Future<void> clearAll() async {
    try {
      await _interviewBox.clear();
      print('✓ All interviews cleared from Hive');
    } catch (e) {
      print('❌ Error clearing Hive: $e');
      rethrow;
    }
  }
  
  // Helper: Map to InterviewModel
  InterviewModel _mapToInterview(String id, Map data) {
    return InterviewModel(
      id: id,
      recruiterId: data['recruiterId'] ?? '',
      candidateId: data['candidateId'] ?? '',
      candidateName: data['candidateName'] ?? '',
      candidateRole: data['candidateRole'] ?? '',
      interviewTime: data['interviewTime'] ?? '',
      meetLink: data['meetLink'] == '' ? null : data['meetLink'],
      status: data['status'] ?? 'pending',
      interviewType: data['interviewType'] ?? 'meet',
      officeAddress: data['officeAddress'] == '' ? null : data['officeAddress'],
      applicationId: data['applicationId'] == '' ? null : data['applicationId'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      startedAt: (data['startedAt'] == '' || data['startedAt'] == null) 
          ? null 
          : DateTime.parse(data['startedAt']),
      endedAt: (data['endedAt'] == '' || data['endedAt'] == null) 
          ? null 
          : DateTime.parse(data['endedAt']),
    );
  }
}

// Adapter for Hive (TypeAdapter)
class InterviewModelAdapter extends TypeAdapter<InterviewModel> {
  @override
  final typeId = 1;

  @override
  InterviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldId = reader.readByte();
      fields[fieldId] = reader.read();
    }
    return InterviewModel(
      id: fields[0] as String,
      recruiterId: fields[1] as String,
      candidateId: fields[2] as String,
      candidateName: fields[3] as String,
      candidateRole: fields[4] as String,
      interviewTime: fields[5] as String,
      meetLink: fields[6] as String?,
      status: fields[7] as String? ?? 'pending',
      interviewType: fields[8] as String? ?? 'meet',
      officeAddress: fields[9] as String?,
      applicationId: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      startedAt: fields[12] as DateTime?,
      endedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, InterviewModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recruiterId)
      ..writeByte(2)
      ..write(obj.candidateId)
      ..writeByte(3)
      ..write(obj.candidateName)
      ..writeByte(4)
      ..write(obj.candidateRole)
      ..writeByte(5)
      ..write(obj.interviewTime)
      ..writeByte(6)
      ..write(obj.meetLink)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.interviewType)
      ..writeByte(9)
      ..write(obj.officeAddress)
      ..writeByte(10)
      ..write(obj.applicationId)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.startedAt)
      ..writeByte(13)
      ..write(obj.endedAt);
  }
}
