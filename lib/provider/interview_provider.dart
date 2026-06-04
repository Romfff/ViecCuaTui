import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/interview_model.dart';
import '../services/local_db_service.dart';

class InterviewProvider extends ChangeNotifier {
  final LocalDbService _localDbService = LocalDbService.instance;

  bool isLoading = true;
  bool hasError = false;
  List<InterviewModel> _interviews = [];
  List<InterviewModel> _recruiterInterviews = [];
  List<InterviewModel> _candidateInterviews = [];

  InterviewProvider();

  // Get all interviews
  List<InterviewModel> get interviews => _interviews;

  // Get recruiter's interviews
  List<InterviewModel> get recruiterInterviews => _recruiterInterviews;

  // Get candidate's interviews
  List<InterviewModel> get candidateInterviews => _candidateInterviews;

  // Listen to recruiter interviews (Load from SQLite)
  void listenRecruiterInterviews(String recruiterId) {
    isLoading = true;
    notifyListeners();
    
    _localDbService.getRecruiterInterviews(recruiterId).then((interviews) {
      _recruiterInterviews = interviews;
      print('✓ Loaded ${interviews.length} recruiter interviews from SQLite');
      
      isLoading = false;
      hasError = false;
      notifyListeners();
    }).catchError((e) {
      print('❌ Error loading recruiter interviews from SQLite: $e');
      isLoading = false;
      hasError = true;
      notifyListeners();
    });
  }

  // Listen to candidate interviews (Load from SQLite)
  void listenCandidateInterviews(String candidateId) {
    isLoading = true;
    notifyListeners();
    
    _localDbService.getCandidateInterviews(candidateId).then((interviews) {
      _candidateInterviews = interviews;
      print('✓ Loaded ${interviews.length} candidate interviews from SQLite');
      
      isLoading = false;
      hasError = false;
      notifyListeners();
    }).catchError((e) {
      print('❌ Error loading candidate interviews from SQLite: $e');
      isLoading = false;
      hasError = true;
      notifyListeners();
    });
  }

  // Create new interview (Save to SQLite only)
  Future<String?> createInterview(InterviewModel interview) async {
    try {
      print('=== InterviewProvider.createInterview START (SQLite only) ===');
      
      // Generate unique ID locally
      const uuid = Uuid();
      final id = uuid.v4();
      
      // Create interview with generated ID
      final interviewWithId = interview.copyWith(
        id: id,
        createdAt: DateTime.now(),
      );
      
      // Save to SQLite only
      await _localDbService.saveInterview(interviewWithId);
      print('✓ Interview saved to SQLite with ID: $id');
      
      // Add to local recruiter interviews list
      _recruiterInterviews.add(interviewWithId);
      notifyListeners();
      
      print('✓ Interview created successfully with ID: $id');
      return id;
    } catch (e) {
      print('❌ Error creating interview: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Update meet link (SQLite only)
  Future<bool> updateMeetLink(String interviewId, String meetLink) async {
    try {
      // Update local state
      final index = _recruiterInterviews.indexWhere((i) => i.id == interviewId);
      if (index != -1) {
        final updated = _recruiterInterviews[index].copyWith(
          meetLink: meetLink,
        );
        _recruiterInterviews[index] = updated;
        
        // Update SQLite
        await _localDbService.updateInterview(updated);
        print('✓ Interview meet link updated in SQLite: $interviewId');
        
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      print('❌ Lỗi cập nhật meet link: $e');
      return false;
    }
  }

  // Update interview (SQLite only)
  Future<bool> updateInterview(InterviewModel interview) async {
    try {
      // Update local state
      final index = _recruiterInterviews.indexWhere((i) => i.id == interview.id);
      if (index != -1) {
        _recruiterInterviews[index] = interview;
        
        // Update SQLite
        await _localDbService.updateInterview(interview);
        print('✓ Interview updated in SQLite: ${interview.id}');
        
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      print('❌ Lỗi cập nhật interview: $e');
      return false;
    }
  }

  // Update interview status (SQLite only)
  Future<bool> updateInterviewStatus(String interviewId, String status) async {
    try {
      // Update local state
      final index = _recruiterInterviews.indexWhere((i) => i.id == interviewId);
      if (index != -1) {
        final updated = _recruiterInterviews[index].copyWith(status: status);
        _recruiterInterviews[index] = updated;
        
        // Update SQLite
        await _localDbService.updateInterview(updated);
        print('✓ Interview status updated in SQLite: $interviewId');
        
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('❌ Lỗi cập nhật status: $e');
      return false;
    }
  }

  // Delete interview (SQLite only)
  Future<bool> deleteInterview(String interviewId) async {
    try {
      _recruiterInterviews.removeWhere((i) => i.id == interviewId);
      
      // Delete from SQLite
      await _localDbService.deleteInterview(interviewId);
      print('✓ Interview deleted from SQLite: $interviewId');
      notifyListeners();
      
      return true;
    } catch (e) {
      print('❌ Lỗi xóa interview: $e');
      return false;
    }
  }
}
