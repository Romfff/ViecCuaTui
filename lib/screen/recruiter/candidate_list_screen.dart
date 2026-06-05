import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/application_model.dart';
import '../../provider/notification_provider.dart';
import '../../provider/application_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';
import 'candidate_cv_detail_screen.dart';

const _kNavy = Color(0xFF0D1B4B);
const _kGreenAccent = Color(0xFF0FB488);
const _kBg = Color(0xFFF8F9FB);
const _kTextSub = Color(0xFF8E8E93);

class CandidateListScreen extends StatefulWidget {
  const CandidateListScreen({super.key});

  @override
  State<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends State<CandidateListScreen> {
  String _filterStatus = 'all'; // all, pending, accepted, rejected

  @override
  void initState() {
    super.initState();
    // Fetch all applications - filter client-side
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationProvider>().fetchApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobProv = context.watch<JobProvider>();
    
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ứng Viên Nộp CV',
          style: TextStyle(
            color: _kNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất Cả', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Chờ Duyệt', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đã Chấp Nhận', 'accepted'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Từ Chối', 'rejected'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Candidates list
          Expanded(
            child: Consumer2<ApplicationProvider, NotificationProvider>(
              builder: (context, appProvider, notifProvider, _) {
                // Get recruiter's job IDs
                final recruiterJobs = jobProv.jobs
                    .where((job) => job.posterId == auth.user?.uid)
                    .toList();
                final recruiterJobIds = recruiterJobs.map((job) => job.id).toSet();

                // Get applications for recruiter's jobs only
                final candidatesRaw = appProvider.applications
                    .where((app) => recruiterJobIds.contains(app.jobId))
                    .toList();

                // Deduplicate applications keeping the latest one of each candidate per job
                final candidatesMap = <String, ApplicationModel>{};
                for (var app in candidatesRaw) {
                  candidatesMap['${app.applicantId}_${app.jobId}'] = app;
                }
                final candidates = candidatesMap.values.toList();

                List<ApplicationModel> filtered = candidates;
                if (_filterStatus != 'all') {
                  filtered = candidates.where((candidate) {
                    final status = notifProvider.getCvDecision('${candidate.applicantId}_${candidate.jobId}');
                    return status == _filterStatus;
                  }).toList();
                }

                if (appProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (appProvider.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Lỗi khi tải dữ liệu',
                          style: TextStyle(
                            color: _kNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            appProvider.errorMessage,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, color: _kTextSub, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Không có ứng viên',
                          style: TextStyle(
                            color: _kNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final candidate = filtered[index];
                    final status = notifProvider.getCvDecision('${candidate.applicantId}_${candidate.jobId}');
                    return _buildCandidateCard(context, candidate, status);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _filterStatus == value,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: _kGreenAccent,
      labelStyle: TextStyle(
        color: _filterStatus == value ? Colors.white : _kNavy,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(
        color: _filterStatus == value ? _kGreenAccent : Colors.transparent,
      ),
    );
  }

  Widget _buildCandidateCard(
    BuildContext context,
    ApplicationModel candidate,
    String? status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: const Icon(Icons.person, color: _kNavy, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.applicantName,
                      style: const TextStyle(
                        color: _kNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.position,
                      style: const TextStyle(
                        color: _kTextSub,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: status == 'accepted'
                        ? _kGreenAccent.withOpacity(0.2)
                        : status == 'rejected'
                            ? Colors.red.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status == 'accepted'
                        ? 'Đã Duyệt'
                        : status == 'rejected'
                            ? 'Từ Chối'
                            : 'Chờ Duyệt',
                    style: TextStyle(
                      color: status == 'accepted'
                          ? _kGreenAccent
                          : status == 'rejected'
                              ? Colors.red
                              : Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.email, color: _kTextSub, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  candidate.applicantEmail,
                  style: const TextStyle(
                    color: _kTextSub,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone, color: _kTextSub, size: 16),
              const SizedBox(width: 8),
              Text(
                candidate.phone,
                style: const TextStyle(
                  color: _kTextSub,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (status == null)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print('Navigate to CV detail: ${candidate.applicantName}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CandidateCvDetailScreen(
                            name: candidate.applicantName,
                            role: candidate.position,
                            cvBody: 'CV of ${candidate.applicantName}',
                            fromCandidateList: true,
                            applicantId: candidate.applicantId,
                            jobId: candidate.jobId,
                            jobTitle: candidate.jobTitle,
                            jobCompany: candidate.jobCompany,
                          ),
                        ),
                      ).then((_) {
                        print('Returned from CV detail, updating state');
                        setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreenAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Xem CV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      print('Reject candidate: ${candidate.applicantName}');
                      context
                          .read<NotificationProvider>()
                          .setCvDecision('${candidate.applicantId}_${candidate.jobId}', 'rejected');
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã từ chối ứng viên'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Từ Chối', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )
          else if (status == 'accepted')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreenAccent,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Đã Chấp Nhận', style: TextStyle(fontSize: 12)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Đã Từ Chối', style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}
