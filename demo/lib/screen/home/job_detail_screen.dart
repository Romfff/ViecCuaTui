import 'package:flutter/material.dart';
import '../../models/job_model.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(job.company, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(job.location, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 8),
            Text('Mức lương: ${job.salary}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Loại công việc: ${job.type}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Text('Mô tả công việc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(job.description, style: TextStyle(fontSize: 15, height: 1.4)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ứng tuyển thành công!')));
              },
              icon: Icon(Icons.send),
              label: Text('Ứng tuyển ngay'),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      ),
    );
  }
}
