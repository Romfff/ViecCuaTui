import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationService {
  final CollectionReference applicationsRef = FirebaseFirestore.instance.collection('applications');

  Future<void> createApplication(ApplicationModel application) async {
    await applicationsRef.add({
      ...application.toMap(),
      'appliedAt': FieldValue.serverTimestamp(),
    });
  }
}
