import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../models/interview_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';
import '../../provider/notification_provider.dart';
import '../../provider/interview_provider.dart';
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
  const RecruiterHomeScreen({super.key});

  @override
  State<RecruiterHomeScreen> createState() => _RecruiterHomeScreenState();
}

class _RecruiterHomeScreenState extends State<RecruiterHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobProv = context.watch<JobProvider>();

    final List<Widget> pages = [
      _DashboardPage(auth: auth),
      _JobsManagementPage(jobProv: jobProv, auth: auth),
      _InterviewsPage(),
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
  const _DashboardPage({required this.auth});

  @override
  Widget build(BuildContext context) {
    final name = auth.user?.email?.split('@').first ?? 'Recruiter';
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
            const Text(
              'Hôm nay có 204 hồ sơ mới đang chờ bạn.',
              style: TextStyle(color: _kTextSub, fontSize: 14),
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                  title: 'TIN TUYỂN DỤNG',
                  value: '24',
                  sub: '↗ tăng 12%',
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'HỒ SƠ MỚI',
                  value: '856',
                  sub: '204 hôm nay',
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'ĐÃ PHỎNG VẤN',
                  value: '18',
                  sub: 'Tháng này',
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'CHỜ PHỎNG VẤN',
                  value: '42',
                  sub: '! Cần xử lý',
                  color: Colors.red,
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
            _CandidateItem(
              name: 'Alexandra Chen',
              role: 'Senior UI Designer',
              match: '98%',
              cvBody: 'Kính gửi Nhà tuyển dụng,\n\nTôi là Alexandra Chen, chuyên viên thiết kế giao diện người dùng với hơn 6 năm kinh nghiệm trong lĩnh vực FinTech và Mobile App. Tôi đã hoàn thành nhiều dự án thiết kế từ nghiên cứu người dùng đến prototypes và hệ thống thiết kế toàn diện. Tôi tự tin mang đến trải nghiệm trực quan, hiện đại và thân thiện cho sản phẩm của công ty.',
            ),
            _CandidateItem(
              name: 'Julian Blackwood',
              role: 'Product Manager',
              match: '85%',
              cvBody: 'Xin chào,\n\nTôi là Julian Blackwood, Product Manager với hơn 8 năm điều phối sản phẩm từ chiến lược đến triển khai. Tôi đã dẫn dắt các nhóm đa chức năng và phát triển các roadmap gắn liền với mục tiêu kinh doanh. Tôi mong muốn tham gia đội ngũ của quý công ty để thúc đẩy sản phẩm đạt tăng trưởng bền vững.',
            ),
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
  @override
  State<_InterviewsPage> createState() => _InterviewsPageState();
}

class _InterviewsPageState extends State<_InterviewsPage> {
  final GoogleMeetService _meetService = GoogleMeetService();
  final Map<String, String?> _meetingLinks = {};
  final Map<String, String?> _interviewIds = {}; // Track interview IDs by candidate name
  final Map<String, TextEditingController> _meetLinkControllers = {};
  late InterviewProvider _interviewProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interviewProvider = context.read<InterviewProvider>();
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        _interviewProvider.listenRecruiterInterviews(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _meetLinkControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _showMeetLinkDialog(
    String candidateName,
    String candidateRole,
    String interviewTime,
  ) async {
    _meetLinkControllers[candidateName] ??= TextEditingController();
    final linkController = _meetLinkControllers[candidateName]!;
    linkController.clear();

    DateTime? selectedStartTime;
    DateTime? selectedEndTime;

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
                      final auth = context.read<AuthProvider>();

                      try {
                        final existingId = _interviewIds[candidateName];

                        if (existingId != null) {
                          await _interviewProvider.updateInterview(
                            InterviewModel(
                              id: existingId,
                              recruiterId: auth.user?.uid ?? '',
                              candidateId: '',
                              candidateName: candidateName,
                              candidateRole: candidateRole,
                              interviewTime: interviewTime,
                              meetLink: link,
                              startedAt: selectedStartTime,
                              endedAt: selectedEndTime,
                              status: 'ongoing',
                              createdAt: DateTime.now(),
                            ),
                          );
                        } else {
                          final interview = InterviewModel(
                            id: '',
                            recruiterId: auth.user?.uid ?? '',
                            candidateId: '',
                            candidateName: candidateName,
                            candidateRole: candidateRole,
                            interviewTime: interviewTime,
                            meetLink: link,
                            startedAt: selectedStartTime,
                            endedAt: selectedEndTime,
                            status: 'ongoing',
                            createdAt: DateTime.now(),
                          );

                          final interviewId = await _interviewProvider
                              .createInterview(interview);
                          if (interviewId != null) {
                            _interviewIds[candidateName] = interviewId;
                          }
                        }

                        setState(() {
                          _meetingLinks[candidateName] = link;
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Đã lưu link & thời gian'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
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
    return SafeArea(
      child: SingleChildScrollView(
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
            const Text(
              'Bạn có 3 cuộc phỏng vấn hôm nay',
              style: TextStyle(color: _kTextSub),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DateNode(day: 'TH 2', date: '12'),
                _DateNode(day: 'TH 3', date: '13'),
                _DateNode(day: 'TH 4', date: '14', isSelected: true),
                _DateNode(day: 'TH 5', date: '15'),
                _DateNode(day: 'TH 6', date: '16'),
              ],
            ),
            const SizedBox(height: 30),
            _InterviewCard(
              time: _meetingLinks['Alexander Sterling'] != null ? '09:00 - 10:00' : 'Chưa diễn ra',
              name: 'Alexander Sterling',
              role: 'Senior Product Architect',
              status: _meetingLinks['Alexander Sterling'] != null ? 'ĐANG DIỄN RA' : 'SẮP TỚI',
              isOnline: true,
              onOpenMeet: _openGoogleMeet,
              onPasteMeetLink: () => _showMeetLinkDialog(
                'Alexander Sterling',
                'Senior Product Architect',
                '09:00 - 10:00',
              ),
              meetLink: _meetingLinks['Alexander Sterling'],
            ),
            _InterviewCard(
              time: _meetingLinks['Minh Anh Nguyễn'] != null ? '13:30 - 14:30' : 'Chưa diễn ra',
              name: 'Minh Anh Nguyễn',
              role: 'Lead DevOps Engineer',
              status: _meetingLinks['Minh Anh Nguyễn'] != null ? 'ĐANG DIỄN RA' : 'SẮP TỚI',
              isOnline: false,
              onOpenMeet: _openGoogleMeet,
              onPasteMeetLink: () => _showMeetLinkDialog(
                'Minh Anh Nguyễn',
                'Lead DevOps Engineer',
                '13:30 - 14:30',
              ),
              meetLink: _meetingLinks['Minh Anh Nguyễn'],
            ),
          ],
        ),
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
  const _StatCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _kTextSub,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _kNavy,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateItem extends StatelessWidget {
  final String name, role, match, cvBody;
  const _CandidateItem({
    required this.name,
    required this.role,
    required this.match,
    required this.cvBody,
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
