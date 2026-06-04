import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationService {
  final CollectionReference applicationsRef = FirebaseFirestore.instance.collection('applications');

  // Get all applications as stream
  Stream<List<ApplicationModel>> getApplicationsStream() {
    return applicationsRef
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // Get applications by job IDs (for recruiter's jobs)
  Stream<List<ApplicationModel>> getApplicationsByJobIdsStream(List<String> jobIds) {
    if (jobIds.isEmpty) {
      return Stream.value([]);
    }
    
    return applicationsRef
        .where('jobId', whereIn: jobIds)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // Add new application
  Future<String> addApplication(ApplicationModel application) async {
    final docRef = await applicationsRef.add({
      'jobId': application.jobId,
      'jobTitle': application.jobTitle,
      'jobCompany': application.jobCompany,
      'applicantId': application.applicantId,
      'applicantName': application.applicantName,
      'applicantEmail': application.applicantEmail,
      'phone': application.phone,
      'address': application.address,
      'position': application.position,
      'experience': application.experience,
      'education': application.education,
      'skills': application.skills,
      'coverLetter': application.coverLetter,
      'appliedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> createApplication(ApplicationModel application) async {
    await applicationsRef.add({
      ...application.toMap(),
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }
}
