import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../models/interview_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';
import '../../provider/notification_provider.dart';
import '../../provider/interview_provider.dart';
import '../../provider/application_provider.dart';
import '../chat/chat_list_screen.dart';
import '../notifications/notification_screen.dart';
import 'candidate_cv_detail_screen.dart';
import 'candidate_list_screen.dart';
import 'post_job_screen.dart';
import 'edit_job_screen.dart';
import '../home/job_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/google_meet_service.dart';

const _kNavy = Color(0xFF0D1B4B);
const _kGreenAccent = Color(0xFF0FB488);
const _kBg = Color(0xFFF8F9FB);
const _kTextSub = Color(0xFF8E8E93);

class RecruiterHomeScreen extends StatefulWidget {
  final int initialIndex;
  final DateTime? initialDate;

  const RecruiterHomeScreen({
    super.key,
    this.initialIndex = 0,
    this.initialDate,
  });

  @override
  State<RecruiterHomeScreen> createState() => _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends State<RecruiterHomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<InterviewProvider>().listenRecruiterInterviews(auth.user!.uid);
        context.read<ApplicationProvider>().fetchApplications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobProv = context.watch<JobProvider>();

    final List<Widget> pages = [
      _DashboardPage(
        auth: auth,
        onTabSelect: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      _JobsManagementPage(jobProv: jobProv, auth: auth),
      _InterviewsPage(initialDate: widget.initialDate),
      const CandidateListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _kGreenAccent,
          unselectedItemColor: _kTextSub,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center_outlined),
              activeIcon: Icon(Icons.business_center),
              label: 'JOBS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note),
              label: 'INTERVIEWS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'TALENT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  final AuthProvider auth;
  final ValueChanged<int>? onTabSelect;
  const _DashboardPage({required this.auth, this.onTabSelect});

  @override
  Widget build(BuildContext context) {
    final name = auth.user?.email?.split('@').first ?? 'Recruiter';
    
    // Watch real database-backed providers
    final jobProv = context.watch<JobProvider>();
    final appProv = context.watch<ApplicationProvider>();
    final interviewProv = context.watch<InterviewProvider>();
    final notifProv = context.watch<NotificationProvider>();

    // 1. Calculate Posted Jobs Statistics (TIN TUYỂN DỤNG)
    final recruiterJobs = jobProv.jobs.where((job) => job.posterId == auth.user?.uid).toList();
    final activeJobsCount = recruiterJobs.where((job) => job.status == 'published').length;

    // 2. Calculate Received CVs/Applications Statistics (HỒ SƠ MỚI)
    final recruiterJobIds = recruiterJobs.map((job) => job.id).toSet();
    final recruiterApps = appProv.applications.where((app) => recruiterJobIds.contains(app.jobId)).toList();
    final pendingApps = recruiterApps.where((app) => notifProv.getCvDecision(app.applicantName) == null).toList();

    // 3. Calculate Completed Interviews Statistics (ĐÃ PHỎNG VẤN)
    final completedInterviewsCount = interviewProv.recruiterInterviews.where((i) => i.status == 'completed').length;

    // 4. Calculate Upcoming/Pending Interviews Statistics (CHỜ PHỎNG VẤN)
    final pendingInterviewsCount = interviewProv.recruiterInterviews.where((i) => i.status == 'pending' || i.status == 'ongoing').length;

    // Filter latest candidates to show only those who applied today
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayApps = recruiterApps.where((app) {
      if (app.appliedAt == null) return false;
      return app.appliedAt!.isAfter(todayStart);
    }).toList();
    final latestApps = todayApps.reversed.toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: _kNavy,
                  radius: 22,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatListScreen(),
                    ),
                  ),
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: _kNavy,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  ),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: _kNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(
              'Xin chào, $name',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: _kNavy,
              ),
            ),
            Text(
              pendingApps.isEmpty
                  ? 'Hiện tại không có hồ sơ mới nào đang chờ bạn.'
                  : 'Hôm nay có ${pendingApps.length} hồ sơ mới đang chờ bạn.',
              style: const TextStyle(color: _kTextSub, fontSize: 14),
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.75,
              children: [
                _StatCard(
                  title: 'TIN TUYỂN DỤNG',
                  value: recruiterJobs.length.toString(),
                  sub: '$activeJobsCount đang hoạt động',
                  color: Colors.blue,
                  onTap: () => onTabSelect?.call(1),
                ),
                _StatCard(
                  title: 'HỒ SƠ MỚI',
                  value: recruiterApps.length.toString(),
                  sub: '${pendingApps.length} chờ duyệt',
                  color: Colors.orange,
                  onTap: () => onTabSelect?.call(3),
                ),
                _StatCard(
                  title: 'ĐÃ PHỎNG VẤN',
                  value: completedInterviewsCount.toString(),
                  sub: 'Đã hoàn thành',
                  color: Colors.green,
                  onTap: () => onTabSelect?.call(2),
                ),
                _StatCard(
                  title: 'CHỜ PHỎNG VẤN',
                  value: pendingInterviewsCount.toString(),
                  sub: 'Lịch sắp tới',
                  color: Colors.red,
                  onTap: () => onTabSelect?.call(2),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Ứng viên mới nhất',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 15),
            if (latestApps.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'Chưa có ứng viên nào nộp hồ sơ hôm nay.',
                    style: TextStyle(color: _kTextSub),
                  ),
                ),
              )
            else
              ...latestApps.map((app) {
                final matchPercent = '${80 + (app.applicantName.length * 3) % 20}%';
                return _CandidateItem(
                  name: app.applicantName,
                  role: app.position,
                  match: matchPercent,
                  cvBody: app.coverLetter.isNotEmpty ? app.coverLetter : 'Hồ sơ ứng tuyển cho vị trí ${app.position}.',
                  applicantId: app.applicantId,
                  jobId: app.jobId,
                  jobTitle: app.jobTitle,
                  jobCompany: app.jobCompany,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class _JobsManagementPage extends StatefulWidget {
  final JobProvider jobProv;
  final AuthProvider auth;
  const _JobsManagementPage({required this.jobProv, required this.auth, Key? key}) : super(key: key);

  @override
  State<_JobsManagementPage> createState() => _JobsManagementPageState();
}

class _JobsManagementPageState extends State<_JobsManagementPage> {
  int _activeTab = 0; // 0: all, 1: published, 2: draft

  @override
  Widget build(BuildContext context) {
    final myJobsAll = widget.jobProv.jobs.where((j) => j.posterId == widget.auth.user?.uid).toList();
    final myJobs = _activeTab == 0
        ? myJobsAll
        : _activeTab == 1
            ? myJobsAll.where((j) => j.status == 'published').toList()
            : myJobsAll.where((j) => j.status == 'draft').toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Quản lý Tin tuyển dụng',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _kNavy,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PostJobScreen(),
                          ),
                        );
                        if (res == 'draft') {
                          setState(() => _activeTab = 2);
                        }
                      },
                      icon: const Icon(Icons.add_business, size: 18),
                      label: const Text('Đăng tin mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreenAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: _kGreenAccent,
                      radius: 18,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _TabChip(label: 'Tất cả', isActive: _activeTab == 0, onTap: () => setState(() => _activeTab = 0)),
                _TabChip(label: 'Đang tuyển', isActive: _activeTab == 1, onTap: () => setState(() => _activeTab = 1)),
                _TabChip(label: 'Bản nháp', isActive: _activeTab == 2, onTap: () => setState(() => _activeTab = 2)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: myJobs.isEmpty ? 1 : myJobs.length,
              itemBuilder: (context, index) {
                if (myJobs.isEmpty) {
                  return const Center(
                    child: Text('Bạn chưa có tin tuyển dụng nào.'),
                  );
                }
                return _JobManageCard(job: myJobs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InterviewsPage extends StatefulWidget {
  final DateTime? initialDate;
  const _InterviewsPage({this.initialDate});

  @override
  State<_InterviewsPage> createState() => _InterviewsPageState();
}

class _InterviewsPageState extends State<_InterviewsPage> {
  final GoogleMeetService _meetService = GoogleMeetService();
  final Map<String, TextEditingController> _meetLinkControllers = {};
  late InterviewProvider _interviewProvider;
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interviewProvider = context.read<InterviewProvider>();
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        _interviewProvider.listenRecruiterInterviews(auth.user!.uid);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _InterviewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate && widget.initialDate != null) {
      _focusedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    for (var controller in _meetLinkControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  DateTime getMonday(DateTime date) {
    int difference = date.weekday - 1;
    return date.subtract(Duration(days: difference));
  }

  List<DateTime> getWeekDays(DateTime mondayDate) {
    return List.generate(7, (index) => mondayDate.add(Duration(days: index)));
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'TH 2';
      case 2:
        return 'TH 3';
      case 3:
        return 'TH 4';
      case 4:
        return 'TH 5';
      case 5:
        return 'TH 6';
      case 6:
        return 'TH 7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  Future<void> _showMeetLinkDialog(InterviewModel interview) async {
    _meetLinkControllers[interview.candidateName] ??= TextEditingController();
    final linkController = _meetLinkControllers[interview.candidateName]!;
    linkController.text = interview.meetLink ?? '';

    DateTime? selectedStartTime = interview.startedAt;
    DateTime? selectedEndTime = interview.endedAt;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nhập link & thời gian Google Meet'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Link Google Meet:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: linkController,
                      decoration: InputDecoration(
                        hintText: 'VD: https://meet.google.com/abc-defg-hij',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.video_camera_front),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    const Text('Thời gian bắt đầu:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          // ignore: use_build_context_synchronously
                          final time = await showTimePicker(
                            // ignore: use_build_context_synchronously
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              selectedStartTime = DateTime(picked.year, picked.month,
                                  picked.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          selectedStartTime == null
                              ? 'Chọn thời gian bắt đầu'
                              : '${selectedStartTime!.day}/${selectedStartTime!.month}/${selectedStartTime!.year} - ${selectedStartTime!.hour}:${selectedStartTime!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              color: selectedStartTime == null
                                  ? Colors.grey
                                  : Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Thời gian kết thúc:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          // ignore: use_build_context_synchronously
                          final time = await showTimePicker(
                            // ignore: use_build_context_synchronously
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              selectedEndTime = DateTime(picked.year, picked.month,
                                  picked.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          selectedEndTime == null
                              ? 'Chọn thời gian kết thúc'
                              : '${selectedEndTime!.day}/${selectedEndTime!.month}/${selectedEndTime!.year} - ${selectedEndTime!.hour}:${selectedEndTime!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                              color: selectedEndTime == null
                                  ? Colors.grey
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final link = linkController.text.trim();
                    if (_meetService.isValidMeetLink(link) &&
                        selectedStartTime != null &&
                        selectedEndTime != null) {
                      try {
                        await _interviewProvider.updateInterview(
                          interview.copyWith(
                            meetLink: link,
                            startedAt: selectedStartTime,
                            endedAt: selectedEndTime,
                            status: 'ongoing',
                          ),
                        );

                        if (!mounted) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Đã lưu link & thời gian'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Lỗi: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Vui lòng nhập đầy đủ thông tin'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreenAccent,
                  ),
                  child: const Text('Lưu',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openGoogleMeet() async {
    final success = await _meetService.openGoogleMeet();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Không thể mở Google Meet'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    int daysCount = 8;
    if (widget.initialDate != null) {
      final initialDateClean = DateTime(widget.initialDate!.year, widget.initialDate!.month, widget.initialDate!.day);
      final diff = initialDateClean.difference(todayDate).inDays;
      if (diff > 7) {
        daysCount = diff + 1;
      }
    }
    final scrollableDays = List.generate(daysCount, (index) => todayDate.add(Duration(days: index)));

    return SafeArea(
      child: Consumer<InterviewProvider>(
        builder: (context, interviewProvider, _) {
          final interviews = interviewProvider.recruiterInterviews;
          
          // Filter interviews for the selected day
          final filteredInterviews = interviews.where((interview) {
            try {
              final parts = interview.interviewTime.split(' - ');
              final dateParts = parts[0].split('/');
              final day = int.parse(dateParts[0]);
              final month = int.parse(dateParts[1]);
              final year = int.parse(dateParts[2]);
              
              final interviewDate = DateTime(year, month, day);
              return interviewDate.day == _focusedDate.day &&
                  interviewDate.month == _focusedDate.month &&
                  interviewDate.year == _focusedDate.year;
            } catch (e) {
              return false;
            }
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch phỏng vấn',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _kNavy,
                  ),
                ),
                Text(
                  filteredInterviews.isEmpty
                      ? 'Bạn chưa có lịch phỏng vấn nào hôm nay'
                      : 'Bạn có ${filteredInterviews.length} cuộc phỏng vấn hôm nay',
                  style: const TextStyle(color: _kTextSub),
                ),
                const SizedBox(height: 25),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: scrollableDays.map((day) {
                      final isSelected = _focusedDate.day == day.day &&
                          _focusedDate.month == day.month &&
                          _focusedDate.year == day.year;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _focusedDate = day;
                            });
                          },
                          child: _DateNode(
                            day: _getWeekdayName(day.weekday),
                            date: day.day.toString(),
                            isSelected: isSelected,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                if (filteredInterviews.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today, color: _kTextSub, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Chưa có cuộc phỏng vấn nào',
                            style: TextStyle(
                              color: _kNavy,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filteredInterviews.map((interview) {
                    return _InterviewCard(
                      time: interview.interviewTime.split(' - ').last,
                      name: interview.candidateName,
                      role: interview.candidateRole,
                      status: interview.status == 'pending' ? 'SẮP TỚI' : 'ĐANG DIỄN RA',
                      isOnline: interview.interviewType == 'meet',
                      meetLink: interview.meetLink,
                      onOpenMeet: _openGoogleMeet,
                      onPasteMeetLink: () => _showMeetLinkDialog(interview),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TalentSourcePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tuyền tập\nNhân tài Ưu tú',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 20),
            _TalentCard(
              name: 'Marcus Holloway',
              role: 'Kiến trúc sư Điện toán Đám mây',
              experience: '12 Năm',
              salary: '185k - 210k',
            ),
            _TalentCard(
              name: 'Elena Rodriguez',
              role: 'Giám đốc Kỹ thuật (VP)',
              experience: '15 Năm',
              salary: '230k - 260k',
            ),
            _TalentCard(
              name: 'Marcus Holloway',
              role: 'Kiến trúc sư Điện toán Đám mây',
              experience: '12 Năm',
              salary: r'$185k - $210k',
            ),
            _TalentCard(
              name: 'Elena Rodriguez',
              role: 'Giám đốc Kỹ thuật (VP)',
              experience: '15 Năm',
              salary: r'$230k - $260k',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, sub;
  final Color color;
  final VoidCallback? onTap;
  const _StatCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _kTextSub,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _kNavy,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CandidateItem extends StatelessWidget {
  final String name, role, match, cvBody;
  final String? applicantId;
  final String? jobId;
  final String? jobTitle;
  final String? jobCompany;

  const _CandidateItem({
    required this.name,
    required this.role,
    required this.match,
    required this.cvBody,
    this.applicantId,
    this.jobId,
    this.jobTitle,
    this.jobCompany,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CandidateCvDetailScreen(
              name: name,
              role: role,
              cvBody: cvBody,
              applicantId: applicantId,
              jobId: jobId,
              jobTitle: jobTitle,
              jobCompany: jobCompany,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, color: _kNavy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    role,
                    style: const TextStyle(fontSize: 12, color: _kTextSub),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGreenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    match,
                    style: const TextStyle(
                      color: _kGreenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<NotificationProvider>().addNotification(
                      NotificationModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: 'Hồ sơ của $name đã được duyệt',
                        subtitle:
                            'Ứng viên $name ($role) đã được xác nhận phỏng vấn.',
                        createdAt: DateTime.now(),
                        recipientRole: 'job_seeker',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã tạo thông báo duyệt hồ sơ.'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(80, 34),
                  ),
                  child: const Text('Duyệt', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JobManageCard extends StatelessWidget {
  final dynamic job;
  const _JobManageCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ĐANG TUYỂN',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: _kTextSub),
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: const Text('Bạn có chắc muốn xóa bài đăng này?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Xóa'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete == true) {
                    await context.read<JobProvider>().removeJob(job.id);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _kNavy,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: _kTextSub),
              const SizedBox(width: 5),
              const Text(
                'Đăng: 12/10/2023',
                style: TextStyle(color: _kTextSub, fontSize: 12),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.group_outlined, size: 16, color: _kTextSub),
              const SizedBox(width: 5),
              const Text(
                '42 Ứng viên',
                style: TextStyle(color: _kTextSub, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobDetailScreen(job: job),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBg,
                    elevation: 0,
                  ),
                  child: const Text(
                    'Xem chi tiết',
                    style: TextStyle(color: _kNavy),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditJobScreen(job: job),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBg,
                    elevation: 0,
                  ),
                  child: const Text(
                    'Chỉnh sửa',
                    style: TextStyle(color: _kNavy),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  final String time, name, role, status;
  final bool isOnline;
  final VoidCallback? onOpenMeet;
  final VoidCallback? onPasteMeetLink;
  final String? meetLink;
  const _InterviewCard({
    required this.time,
    required this.name,
    required this.role,
    required this.status,
    required this.isOnline,
    this.onOpenMeet,
    this.onPasteMeetLink,
    this.meetLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: status == 'ĐANG DIỄN RA' ? Colors.green : Colors.orange,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'ĐANG DIỄN RA'
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'ĐANG DIỄN RA'
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade100,
                child: const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(fontSize: 13, color: _kTextSub),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isOnline
                      ? Icons.video_camera_back_outlined
                      : Icons.business_outlined,
                  size: 20,
                  color: _kNavy,
                ),
                const SizedBox(width: 10),
                Text(
                  isOnline ? 'Google Meet' : 'Văn phòng (P. 402)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          if (meetLink != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Meet: ${meetLink!.split('/').last}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenMeet,
                  icon: const Icon(Icons.video_camera_front),
                  label: const Text('Mở Meet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreenAccent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPasteMeetLink,
                  icon: const Icon(Icons.paste),
                  label: Text(meetLink != null ? 'Sửa' : 'Dán link'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TalentCard extends StatelessWidget {
  final String name, role, experience, salary;
  const _TalentCard({
    required this.name,
    required this.role,
    required this.experience,
    required this.salary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 25, backgroundColor: Colors.grey.shade200),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: _kNavy,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(color: _kTextSub, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'NĂNG LỰC CỐT LÕI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _kTextSub,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['AWS', 'Kubernetes', 'Python']
                .map(
                  (s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 10)),
                    backgroundColor: _kBg,
                    side: BorderSide.none,
                  ),
                )
                .toList(),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KINH NGHIỆM',
                    style: TextStyle(fontSize: 10, color: _kTextSub),
                  ),
                  Text(
                    experience,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'MONG MUỐN',
                    style: TextStyle(fontSize: 10, color: _kTextSub),
                  ),
                  Text(
                    salary,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final profileDetails = '''Họ tên: $name
Chức danh: $role
Kinh nghiệm: $experience
Mức lương mong muốn: $salary

Năng lực cốt lõi:
- AWS
- Kubernetes
- Python

Giới thiệu:
Ứng viên có hơn ${experience.replaceAll(' Năm', '')} năm kinh nghiệm phát triển giải pháp đám mây, lãnh đạo dự án và triển khai kiến trúc microservices cho các hệ thống quy mô lớn. Ứng viên có kỹ năng giao tiếp tốt, tinh thần làm việc nhóm, và phù hợp với môi trường tuyển dụng cao cấp.
''';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CandidateCvDetailScreen(
                      name: name,
                      role: role,
                      cvBody: profileDetails,
                      cvFileName: '${name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_')}_Profile.txt',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBg,
                elevation: 0,
              ),
              child: const Text(
                'Xem hồ sơ đầy đủ',
                style: TextStyle(color: _kNavy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  const _TabChip({required this.label, required this.isActive, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? _kNavy : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : _kNavy,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DateNode extends StatelessWidget {
  final String day, date;
  final bool isSelected;
  const _DateNode({
    required this.day,
    required this.date,
    this.isSelected = false,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? _kNavy : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? Colors.white70 : _kTextSub,
              fontSize: 10,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.white : _kNavy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
