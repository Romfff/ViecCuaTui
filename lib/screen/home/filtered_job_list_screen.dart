import 'package:flutter/material.dart';
import '../../models/job_model.dart';

const _kNavy = Color(0xFF0D1B4B);
const _kAccent = Color(0xFF43E8D8);
const _kTextSec = Color(0xFF8E8E93);

class FilteredJobListScreen extends StatelessWidget {
  final String title;
  final List<JobModel> jobs;

  const FilteredJobListScreen({super.key, required this.title, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kNavy),
        title: Text(
          'Kết quả: $title',
          style: const TextStyle(color: _kNavy, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: jobs.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.search_off, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Không tìm thấy công việc phù hợp.',
                      style: TextStyle(color: _kTextSec, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: _kAccent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  job.company.isNotEmpty ? job.company[0] : '?',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _kAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: const TextStyle(
                                      color: _kNavy,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    job.company,
                                    style: const TextStyle(color: _kTextSec, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: _kAccent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                job.location,
                                style: const TextStyle(fontSize: 12, color: _kTextSec),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.payments_outlined, size: 14, color: _kAccent),
                            const SizedBox(width: 6),
                            Text(
                              job.salary,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _kNavy),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              job.type,
                              style: const TextStyle(fontSize: 12, color: _kTextSec),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
