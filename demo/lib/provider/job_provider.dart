import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';

class JobProvider extends ChangeNotifier {
  final JobService _jobService = JobService();

  bool isLoading = true;
  bool hasError = false;
  String _searchTerm = '';
  List<JobModel> _jobs = [];

  JobProvider() {
    _listenJobs();
  }

  void _listenJobs() {
    _jobService.getJobsStream().listen((jobs) {
      _jobs = jobs;
      isLoading = false;
      hasError = false;
      notifyListeners();
    }, onError: (_) {
      isLoading = false;
      hasError = true;
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

  Future<void> updateJob(JobModel job) async {
    await _jobService.updateJob(job);
  }

  Future<void> removeJob(String jobId) async {
    await _jobService.deleteJob(jobId);
  }

  List<JobModel> getBookmarkedJobs(List<String> bookmarkedIds) {
    return _jobs.where((job) => bookmarkedIds.contains(job.id)).toList();
  }
}
