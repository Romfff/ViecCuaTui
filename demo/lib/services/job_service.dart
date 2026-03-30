import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobService {
  final CollectionReference jobsRef = FirebaseFirestore.instance.collection('jobs');

  Stream<List<JobModel>> getJobsStream() {
    return jobsRef.orderBy('postedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((e) => JobModel.fromMap(e.id, {
                    ...e.data() as Map<String, dynamic>,
                    'postedDate': _formatPostedDate((e.data() as Map<String, dynamic>)['postedAt']),
                  }))
              .toList(),
        );
  }

  Future<void> createJob(JobModel job) async {
    await jobsRef.add({
      ...job.toMap(),
      'postedAt': FieldValue.serverTimestamp(),
    });
  }

  String _formatPostedDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Mới đăng';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}
