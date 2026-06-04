class ApplicationModel {
  final String? id;
  final String jobId;
  final String jobTitle;
  final String jobCompany;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String phone;
  final String address;
  final String position;
  final String experience;
  final String education;
  final String skills;
  final String coverLetter;
  final DateTime? appliedAt;

  ApplicationModel({
    this.id,
    required this.jobId,
    required this.jobTitle,
    required this.jobCompany,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.phone,
    required this.address,
    required this.position,
    required this.experience,
    required this.education,
    required this.skills,
    required this.coverLetter,
    this.appliedAt,
  });

  factory ApplicationModel.fromMap(String id, Map<String, dynamic> data) {
    DateTime? parsedDate;
    if (data['appliedAt'] != null) {
      if (data['appliedAt'] is DateTime) {
        parsedDate = data['appliedAt'];
      } else if (data['appliedAt'] is String) {
        parsedDate = DateTime.tryParse(data['appliedAt']);
      } else {
        // If it's a Firestore Timestamp or similar
        try {
          parsedDate = (data['appliedAt'] as dynamic).toDate();
        } catch (_) {
          // fallback
        }
      }
    }
    return ApplicationModel(
      id: id,
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      jobCompany: data['jobCompany'] ?? '',
      applicantId: data['applicantId'] ?? '',
      applicantName: data['applicantName'] ?? '',
      applicantEmail: data['applicantEmail'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      position: data['position'] ?? '',
      experience: data['experience'] ?? '',
      education: data['education'] ?? '',
      skills: data['skills'] ?? '',
      coverLetter: data['coverLetter'] ?? '',
      appliedAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'jobCompany': jobCompany,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'phone': phone,
      'address': address,
      'position': position,
      'experience': experience,
      'education': education,
      'skills': skills,
      'coverLetter': coverLetter,
      'appliedAt': appliedAt,
    };
  }
}
