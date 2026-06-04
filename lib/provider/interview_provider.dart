import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interview_model.dart';
import '../services/interview_service.dart';

class InterviewProvider extends ChangeNotifier {
  final InterviewService _interviewService = InterviewService();

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

  // Listen to recruiter interviews
  void listenRecruiterInterviews(String recruiterId) {
    _interviewService
        .getRecruiterInterviewsStream(recruiterId)
        .listen((interviews) {
      _recruiterInterviews = interviews;
      isLoading = false;
      hasError = false;
      notifyListeners();
    }, onError: (_) {
      isLoading = false;
      hasError = true;
      notifyListeners();
    });
  }

  // Listen to candidate interviews
  void listenCandidateInterviews(String candidateId) {
    _interviewService
        .getCandidateInterviewsStream(candidateId)
        .listen((interviews) {
      _candidateInterviews = interviews;
      isLoading = false;
      hasError = false;
      notifyListeners();
    }, onError: (_) {
      isLoading = false;
      hasError = true;
      notifyListeners();
    });
  }

  // Create new interview
  Future<String?> createInterview(InterviewModel interview) async {
    try {
      print('InterviewProvider.createInterview: Starting...');
      print('Creating interview: ${interview.toMap()}');
      final id = await _interviewService.createInterview(interview);
      print('InterviewProvider.createInterview: Success with ID: $id');
      
      // Validate ID is not empty
      if (id.isEmpty) {
        print('Warning: Interview ID is empty!');
        return null;
      }
      
      return id;
    } on FirebaseException catch (e) {
      print('Lỗi Firebase tạo interview: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Lỗi tạo interview: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Update meet link
  Future<bool> updateMeetLink(String interviewId, String meetLink) async {
    try {
      await _interviewService.updateMeetLink(interviewId, meetLink);
      
      // Update local state
      final index = _recruiterInterviews.indexWhere((i) => i.id == interviewId);
      if (index != -1) {
        _recruiterInterviews[index] = _recruiterInterviews[index].copyWith(
          meetLink: meetLink,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      print('Lỗi cập nhật meet link: $e');
      return false;
    }
  }

  // Update interview (link, times, etc)
  Future<bool> updateInterview(InterviewModel interview) async {
    try {
      await _interviewService.updateInterview(interview);
      
      // Update local state
      final index = _recruiterInterviews.indexWhere((i) => i.id == interview.id);
      if (index != -1) {
        _recruiterInterviews[index] = interview;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      print('Lỗi cập nhật interview: $e');
      return false;
    }
  }

  // Update interview status
  Future<bool> updateInterviewStatus(
      String interviewId, String status) async {
    try {
      await _interviewService.updateInterviewStatus(interviewId, status);

      // Update local state
      final index = _recruiterInterviews.indexWhere((i) => i.id == interviewId);
      if (index != -1) {
        _recruiterInterviews[index] =
            _recruiterInterviews[index].copyWith(status: status);
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('Lỗi cập nhật status: $e');
      return false;
    }
  }

  // Delete interview
  Future<bool> deleteInterview(String interviewId) async {
    try {
      await _interviewService.deleteInterview(interviewId);

      _recruiterInterviews.removeWhere((i) => i.id == interviewId);
      notifyListeners();

      return true;
    } catch (e) {
      print('Lỗi xóa interview: $e');
      return false;
    }
  }
}
