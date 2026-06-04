class InterviewModel {
  final String id;
  final String recruiterId;
  final String candidateId;
  final String candidateName;
  final String candidateRole;
  final String interviewTime;
  final String? meetLink;
  final DateTime? startedAt; // Thời gian bắt đầu cuộc họp
  final DateTime? endedAt;   // Thời gian kết thúc cuộc họp
  final String status; // pending, ongoing, completed
  final DateTime createdAt;
  final String interviewType; // 'office' hoặc 'meet'
  final String? officeAddress; // Địa chỉ văn phòng nếu chọn office
  final String? applicationId; // ID của đơn ứng tuyển

  InterviewModel({
    required this.id,
    required this.recruiterId,
    required this.candidateId,
    required this.candidateName,
    required this.candidateRole,
    required this.interviewTime,
    this.meetLink,
    this.startedAt,
    this.endedAt,
    this.status = 'pending',
    required this.createdAt,
    this.interviewType = 'meet',
    this.officeAddress,
    this.applicationId,
  });

  factory InterviewModel.fromMap(String id, Map<String, dynamic> data) {
    return InterviewModel(
      id: id,
      recruiterId: data['recruiterId'] ?? '',
      candidateId: data['candidateId'] ?? '',
      candidateName: data['candidateName'] ?? '',
      candidateRole: data['candidateRole'] ?? '',
      interviewTime: data['interviewTime'] ?? '',
      meetLink: data['meetLink'],
      startedAt: (data['startedAt'] as dynamic)?.toDate(),
      endedAt: (data['endedAt'] as dynamic)?.toDate(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      interviewType: data['interviewType'] ?? 'meet',
      officeAddress: data['officeAddress'],
      applicationId: data['applicationId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recruiterId': recruiterId,
      'candidateId': candidateId,
      'candidateName': candidateName,
      'candidateRole': candidateRole,
      'interviewTime': interviewTime,
      'meetLink': meetLink,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'status': status,
      'createdAt': createdAt,
      'interviewType': interviewType,
      'officeAddress': officeAddress,
      'applicationId': applicationId,
    };
  }

  InterviewModel copyWith({
    String? id,
    String? recruiterId,
    String? candidateId,
    String? candidateName,
    String? candidateRole,
    String? interviewTime,
    String? meetLink,
    DateTime? startedAt,
    DateTime? endedAt,
    String? status,
    DateTime? createdAt,
    String? interviewType,
    String? officeAddress,
    String? applicationId,
  }) {
    return InterviewModel(
      id: id ?? this.id,
      recruiterId: recruiterId ?? this.recruiterId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      candidateRole: candidateRole ?? this.candidateRole,
      interviewTime: interviewTime ?? this.interviewTime,
      meetLink: meetLink ?? this.meetLink,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      interviewType: interviewType ?? this.interviewType,
      officeAddress: officeAddress ?? this.officeAddress,
      applicationId: applicationId ?? this.applicationId,
    );
  }
}
