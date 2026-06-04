import 'dart:async';
import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationService _applicationService = ApplicationService();
  
  StreamSubscription? _applicationSubscription;

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  List<ApplicationModel> _applications = [];

  List<ApplicationModel> get applications => _applications;

  ApplicationProvider() {
    // Initialize by fetching applications
    fetchApplications();
  }

  void fetchApplications() {
    _applicationSubscription?.cancel();
    _applicationSubscription = _applicationService.getApplicationsStream().listen(
      (applications) {
        print('ApplicationProvider: Fetched ${applications.length} applications');
        _applications = applications;
        isLoading = false;
        hasError = false;
        errorMessage = '';
        notifyListeners();
      },
      onError: (error) {
        print('ApplicationProvider: Error fetching applications: $error');
        isLoading = false;
        hasError = true;
        errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  // Fetch applications for specific job IDs (for recruiter)
  void fetchApplicationsByJobIds(List<String> jobIds) {
    print('ApplicationProvider: fetchApplicationsByJobIds with ${jobIds.length} jobs');
    _applicationSubscription?.cancel();
    _applicationSubscription = _applicationService.getApplicationsByJobIdsStream(jobIds).listen(
      (applications) {
        print('ApplicationProvider: Fetched ${applications.length} applications for recruiter');
        _applications = applications;
        isLoading = false;
        hasError = false;
        notifyListeners();
      },
      onError: (error) {
        print('ApplicationProvider: Error fetching applications by job IDs: $error');
        isLoading = false;
        hasError = true;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _applicationSubscription?.cancel();
    super.dispose();
  }

  Future<String?> submitApplication(ApplicationModel application) async {
    try {
      final id = await _applicationService.addApplication(application);
      // Refresh applications list
      fetchApplications();
      return id;
    } catch (e) {
      print('Error submitting application: $e');
      return null;
    }
  }
}
