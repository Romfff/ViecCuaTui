import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';

class JobProvider extends ChangeNotifier {
  final JobService _jobService = JobService();

  bool isLoading = true;
  String _searchTerm = '';
  List<JobModel> _jobs = [];

  JobProvider() {
    _listenJobs();
  }

  void _listenJobs() {
    _jobService.getJobsStream().listen((jobs) {
      _jobs = jobs;
      isLoading = false;
      notifyListeners();
    }, onError: (error) {
      isLoading = false;
      notifyListeners();
    });
  }

  List<JobModel> get jobs {
    if (_searchTerm.isEmpty) return _jobs;
    final term = _searchTerm.toLowerCase();
    return _jobs.where((job) {
      return job.title.toLowerCase().contains(term) ||
          job.company.toLowerCase().contains(term) ||
          job.location.toLowerCase().contains(term);
    }).toList();
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  Future<void> addJob(JobModel job) async {
    await _jobService.createJob(job);
  }
}

