import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/application_model.dart';

class ApplicationService {
  static const String _boxName = 'applications';
  Box<Map>? _box;

  Future<Box<Map>> get _openBox async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Map>(_boxName);
    return _box!;
  }

  // Get all applications as stream
  Stream<List<ApplicationModel>> getApplicationsStream() async* {
    final box = await _openBox;
    yield _getApplicationsList(box);

    await for (final _ in box.watch()) {
      yield _getApplicationsList(box);
    }
  }

  // Get applications by job IDs (for recruiter's jobs)
  Stream<List<ApplicationModel>> getApplicationsByJobIdsStream(List<String> jobIds) async* {
    if (jobIds.isEmpty) {
      yield [];
      return;
    }
    
    final box = await _openBox;
    yield _getApplicationsList(box, jobIds: jobIds);

    await for (final _ in box.watch()) {
      yield _getApplicationsList(box, jobIds: jobIds);
    }
  }

  List<ApplicationModel> _getApplicationsList(Box<Map> box, {List<String>? jobIds}) {
    final list = <ApplicationModel>[];
    for (var entry in box.toMap().entries) {
      final id = entry.key.toString();
      final rawValue = entry.value;
      final data = Map<String, dynamic>.from(rawValue);
      final app = ApplicationModel.fromMap(id, data);
      
      if (jobIds == null || jobIds.contains(app.jobId)) {
        list.add(app);
      }
    }
    
    // Sort by appliedAt descending
    list.sort((a, b) {
      if (a.appliedAt == null && b.appliedAt == null) return 0;
      if (a.appliedAt == null) return 1;
      if (b.appliedAt == null) return -1;
      return b.appliedAt!.compareTo(a.appliedAt!);
    });
    return list;
  }

  // Add new application
  Future<String> addApplication(ApplicationModel application) async {
    final box = await _openBox;
    final id = application.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final data = {
      ...application.toMap(),
      'id': id,
      'appliedAt': application.appliedAt ?? DateTime.now(),
    };
    await box.put(id, data);
    return id;
  }

  Future<void> createApplication(ApplicationModel application) async {
    final box = await _openBox;
    final id = application.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final data = {
      ...application.toMap(),
      'id': id,
      'appliedAt': application.appliedAt ?? DateTime.now(),
    };
    await box.put(id, data);
  }
}

