class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String description;
  final String postedDate;
  final String posterId;
  final String posterEmail;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.description,
    required this.postedDate,
    required this.posterId,
    required this.posterEmail,
  });

  factory JobModel.fromMap(String id, Map<String, dynamic> data) {
    return JobModel(
      id: id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      salary: data['salary'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      postedDate: data['postedDate'] ?? '',
      posterId: data['posterId'] ?? '',
      posterEmail: data['posterEmail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'type': type,
      'description': description,
      'postedDate': postedDate,
      'posterId': posterId,
      'posterEmail': posterEmail,
    };
  }
}
