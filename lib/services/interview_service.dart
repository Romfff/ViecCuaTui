import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/interview_model.dart';

class InterviewService {
  final CollectionReference interviewsRef =
      FirebaseFirestore.instance.collection('interviews');

  // Get all interviews stream
  Stream<List<InterviewModel>> getInterviewsStream() {
    return interviewsRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) =>
                  InterviewModel.fromMap(e.id, e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // Get interviews by recruiter ID
  Stream<List<InterviewModel>> getRecruiterInterviewsStream(String recruiterId) {
    return interviewsRef
        .where('recruiterId', isEqualTo: recruiterId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) =>
                  InterviewModel.fromMap(e.id, e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // Get interviews by candidate ID
  Stream<List<InterviewModel>> getCandidateInterviewsStream(String candidateId) {
    return interviewsRef
        .where('candidateId', isEqualTo: candidateId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) =>
                  InterviewModel.fromMap(e.id, e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // Create new interview
  Future<String> createInterview(InterviewModel interview) async {
    try {
      print('Interview Service: Adding interview to Firestore');
      print('Interview data: recruiterId=${interview.recruiterId}, candidateId=${interview.candidateId}');
      
      final docRef = await interviewsRef.add({
        'recruiterId': interview.recruiterId,
        'candidateId': interview.candidateId,
        'candidateName': interview.candidateName,
        'candidateRole': interview.candidateRole,
        'interviewTime': interview.interviewTime,
        'meetLink': interview.meetLink,
        'startedAt': interview.startedAt,
        'endedAt': interview.endedAt,
        'status': interview.status,
        'interviewType': interview.interviewType,
        'officeAddress': interview.officeAddress,
        'applicationId': interview.applicationId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      final id = docRef.id;
      print('Interview Service: Document added with ID: $id (length: ${id.length})');
      
      // Validate ID is not empty
      if (id.isEmpty) {
        print('ERROR: Interview ID is null or empty!');
        throw Exception('Firestore returned null or empty document ID');
      }
      
      print('Interview Service: Successfully created interview with ID: $id');
      return id;
    } on FirebaseException catch (e) {
      print('Interview Service Firebase Error: ${e.code} - ${e.message}');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    } catch (e) {
      print('Interview Service Error: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Update interview (mainly for meetLink update)
  Future<void> updateInterview(InterviewModel interview) async {
    await interviewsRef.doc(interview.id).update({
      ...interview.toMap(),
    });
  }

  // Update meet link
  Future<void> updateMeetLink(String interviewId, String meetLink) async {
    await interviewsRef.doc(interviewId).update({
      'meetLink': meetLink,
      'status': 'pending',
    });
  }

  // Update interview status
  Future<void> updateInterviewStatus(String interviewId, String status) async {
    await interviewsRef.doc(interviewId).update({
      'status': status,
    });
  }

  // Delete interview
  Future<void> deleteInterview(String interviewId) async {
    await interviewsRef.doc(interviewId).delete();
  }
}
