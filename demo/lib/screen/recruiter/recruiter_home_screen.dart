import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';
import '../profile/profile_screen.dart';
import '../home/job_detail_screen.dart';
import 'edit_job_screen.dart';
import 'post_job_screen.dart';
import '../../services/google_meet_service.dart';

const _kAccent = Color(0xFF43E8D8);
const _kNavy = Color(0xFF0D1B4B);
const _kBg = Color(0xFFF8F9FB);
const _kTextSec = Color(0xFF8E8E93);

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
      const _InterviewsPage(),
      _TalentSourcePage(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _kAccent,
          unselectedItemColor: _kTextSec,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'BẢNG ĐIỀU KHIỂN'),
            BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), activeIcon: Icon(Icons.business_center), label: 'TIN TUYỂN DỤNG'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), activeIcon: Icon(Icons.event_note), label: 'PHỎNG VẤN'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'NHÂN TÀI'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'HỒ SƠ'),
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
    final name = auth.user?.email?.split('@').first ?? 'Admin';
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CHÀO MỪNG TRỞ LẠI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kTextSec)),
                    Text('Chào $name 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _kNavy)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_none_rounded, color: _kNavy),
                )
              ],
            ),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.3,
              children: [
                _StatCard(title: 'TIN TUYỂN DỤNG', value: '24', sub: '↗ tăng 12%', color: _kAccent),
                _StatCard(title: 'HỒ SƠ MỚI', value: '856', sub: '204 hôm nay', color: Colors.orange),
                _StatCard(title: 'ĐÃ PHỎNG VẤN', value: '18', sub: 'Tháng này', color: Colors.green),
                _StatCard(title: 'CHỜ PHỎNG VẤN', value: '42', sub: '! Cần xử lý', color: Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ứng viên mới nhất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kNavy)),
                const Text('Xem tất cả', style: TextStyle(color: _kAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 15),
            const _CandidateItem(name: 'Alexandra Chen', role: 'Senior UI Designer', match: '98%'),
            const _CandidateItem(name: 'Julian Blackwood', role: 'Product Manager', match: '85%'),
          ],
        ),
      ),
    );
  }
}

class _JobsManagementPage extends StatelessWidget {
  final JobProvider jobProv;
  final AuthProvider auth;
  const _JobsManagementPage({required this.jobProv, required this.auth});

  @override
  Widget build(BuildContext context) {
    final myJobs = jobProv.jobs.where((j) => j.posterId == auth.user?.uid).toList();
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text('Quản lý tin tuyển dụng', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _kNavy),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: _kAccent, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.add, size: 18, color: _kNavy),
                        SizedBox(width: 4),
                        Text('Đăng tin', style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: const [
                _TabChip(label: 'Tất cả', isActive: true),
                _TabChip(label: 'Đang tuyển', isActive: false),
                _TabChip(label: 'Bản nháp', isActive: false),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: myJobs.isEmpty ? 1 : myJobs.length,
              itemBuilder: (context, index) {
                if (myJobs.isEmpty) return const Center(child: Text('Bạn chưa có tin tuyển dụng nào.'));
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
  const _InterviewsPage({super.key});

  @override
  State<_InterviewsPage> createState() => _InterviewsPageState();
}

class _InterviewsPageState extends State<_InterviewsPage> {
  bool _isLoading = false;
  String? _generatedLink;

  Future<void> _handleCreateMeet() async {
    setState(() => _isLoading = true);

    final meetService = GoogleMeetService();
    final link = await meetService.createMeeting();

    setState(() {
      _isLoading = false;
      _generatedLink = link;
    });

    if (link != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo phòng họp thành công!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo phòng họp thất bại! Vui lòng kiểm tra quyền truy cập.')),
        );
      }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lịch phỏng vấn', 
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _kNavy)),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCreateMeet,
                  icon: _isLoading
                      ? const SizedBox(width: 16, height: 16, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: _kNavy))
                      : const Icon(Icons.add_link),
                  label: const Text('Tạo Meet', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: _kNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Bạn có 3 cuộc phỏng vấn hôm nay', style: TextStyle(color: _kTextSec)),
            
            if (_generatedLink != null) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(_generatedLink!, 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _DateNode(day: 'TH 2', date: '12'),
                _DateNode(day: 'TH 3', date: '13'),
                _DateNode(day: 'TH 4', date: '14', isSelected: true),
                _DateNode(day: 'TH 5', date: '15'),
                _DateNode(day: 'TH 6', date: '16'),
              ],
            ),
            const SizedBox(height: 30),
            _InterviewCard(
              time: '09:00 - 10:00',
              name: 'Alexander Sterling',
              role: 'Senior Product Architect',
              status: 'ĐANG DIỄN RA',
              isOnline: true,
              link: _generatedLink ?? 'https://meet.google.com/abc-defg-hij',
            ),
            const _InterviewCard(
              time: '13:30 - 14:30',
              name: 'Minh Anh Nguyễn',
              role: 'Lead DevOps Engineer',
              status: 'SẮP TỚI',
              isOnline: false,
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
            const Text('Nguồn nhân tài', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _kNavy)),
            const SizedBox(height: 20),
            _TalentCard(name: 'Marcus Holloway', role: 'Kiến trúc sư Cloud', experience: '12 Năm', salary: r'$185k - $210k'),
            _TalentCard(name: 'Elena Rodriguez', role: 'Giám đốc Kỹ thuật', experience: '15 Năm', salary: r'$230k - $260k'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, sub;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kTextSec)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _kNavy)),
          Text(sub, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CandidateItem extends StatelessWidget {
  final String name, role, match;
  const _CandidateItem({required this.name, required this.role, required this.match});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: _kBg, child: const Icon(Icons.person, color: _kNavy)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(role, style: const TextStyle(fontSize: 12, color: _kTextSec))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _kAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Text(match, style: const TextStyle(color: _kNavy, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _kAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: const Text('ĐANG TUYỂN', style: TextStyle(color: _kNavy, fontSize: 10, fontWeight: FontWeight.bold))),
              const Icon(Icons.more_vert, color: _kTextSec),
            ],
          ),
          const SizedBox(height: 10),
          Text(job.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _kNavy)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(job: job))),
              style: ElevatedButton.styleFrom(backgroundColor: _kBg, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
              child: const Text('Xem chi tiết', style: TextStyle(color: _kNavy, fontSize: 12)))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditJobScreen(job: job))),
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
              child: const Text('Chỉnh sửa', style: TextStyle(color: _kNavy, fontSize: 12, fontWeight: FontWeight.bold)))),
          ]),
        ],
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  final String time, name, role, status;
  final bool isOnline;
  final String? link;
  const _InterviewCard({required this.time, required this.name, required this.role, required this.status, required this.isOnline, this.link});

  Future<void> _launchMeet(BuildContext context) async {
    if (link == null || link!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có link phỏng vấn.')));
      return;
    }
    final Uri url = Uri.parse(link!);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở link Google Meet.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border(left: BorderSide(color: status == 'ĐANG DIỄN RA' ? _kAccent : Colors.orange, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: status == 'ĐANG DIỄN RA' ? _kAccent.withOpacity(0.15) : Colors.orange.shade50, borderRadius: BorderRadius.circular(5)), child: Text(status, style: TextStyle(color: status == 'ĐANG DIỄN RA' ? _kNavy : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 15),
          Row(children: [CircleAvatar(radius: 20, backgroundColor: _kBg, child: const Icon(Icons.person, color: _kNavy)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(role, style: const TextStyle(fontSize: 13, color: _kTextSec))]))]),
          const SizedBox(height: 15),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(isOnline ? Icons.videocam_outlined : Icons.business_outlined, size: 20, color: _kNavy), const SizedBox(width: 10), Text(isOnline ? 'Google Meet' : 'Văn phòng (P. 402)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))])),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: ElevatedButton(
              onPressed: isOnline ? () => _launchMeet(context) : null, 
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent), 
              child: const Text('Tham gia', style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: _kAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Hồ sơ', style: TextStyle(color: _kNavy)))),
          ]),
        ],
      ),
    );
  }
}

class _TalentCard extends StatelessWidget {
  final String name, role, experience, salary;
  const _TalentCard({required this.name, required this.role, required this.experience, required this.salary});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [CircleAvatar(radius: 25, backgroundColor: _kBg, child: const Icon(Icons.person, color: _kNavy)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _kNavy)), Text(role, style: const TextStyle(color: _kTextSec, fontSize: 13))]))]),
          const SizedBox(height: 20),
          const Text('NĂNG LỰC CỐT LÕI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kTextSec)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: const [Chip(label: Text('AWS', style: TextStyle(fontSize: 10)), backgroundColor: _kBg, side: BorderSide.none), Chip(label: Text('Python', style: TextStyle(fontSize: 10)), backgroundColor: _kBg, side: BorderSide.none)]),
          const Divider(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('KINH NGHIỆM', style: TextStyle(fontSize: 10, color: _kTextSec)), Text(experience, style: const TextStyle(fontWeight: FontWeight.bold))]), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('MONG MUỐN', style: TextStyle(fontSize: 10, color: _kTextSec)), Text(salary, style: const TextStyle(fontWeight: FontWeight.bold, color: _kNavy))])]),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: _kAccent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Xem hồ sơ đầy đủ', style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label; final bool isActive;
  const _TabChip({required this.label, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: isActive ? _kNavy : Colors.white, borderRadius: BorderRadius.circular(12)), child: Text(label, style: TextStyle(color: isActive ? Colors.white : _kNavy, fontWeight: FontWeight.bold, fontSize: 13)));
  }
}

class _DateNode extends StatelessWidget {
  final String day, date; final bool isSelected;
  const _DateNode({required this.day, required this.date, this.isSelected = false});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isSelected ? _kNavy : Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(children: [Text(day, style: TextStyle(color: isSelected ? Colors.white70 : _kTextSec, fontSize: 10)), Text(date, style: TextStyle(color: isSelected ? Colors.white : _kNavy, fontSize: 18, fontWeight: FontWeight.bold))]));
  }
}
