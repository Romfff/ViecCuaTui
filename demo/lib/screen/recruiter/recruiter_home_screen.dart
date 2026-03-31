import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';
import '../profile/profile_screen.dart';

// Color Palette for Recruiter
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
          selectedItemColor: _kGreenAccent,
          unselectedItemColor: _kTextSub,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'DASHBOARD'),
            BottomNavigationBarItem(icon: Icon(Icons.business_center_outlined), activeIcon: Icon(Icons.business_center), label: 'JOBS'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), activeIcon: Icon(Icons.event_note), label: 'INTERVIEWS'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'TALENT'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFILE'),
          ],
        ),
      ),
    );
  }
}

// --- TRANG 1: DASHBOARD (Bảng điều khiển - Hình 3) ---
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
                CircleAvatar(backgroundColor: _kNavy, radius: 22, child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
                const Icon(Icons.notifications_none_rounded, color: _kNavy),
              ],
            ),
            const SizedBox(height: 25),
            Text('Xin chào, $name', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _kNavy)),
            const Text('Hôm nay có 204 hồ sơ mới đang chờ bạn.', style: TextStyle(color: _kTextSub, fontSize: 14)),
            const SizedBox(height: 30),
            
            // Grid Stats
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.4,
              children: [
                _StatCard(title: 'TIN TUYỂN DỤNG', value: '24', sub: '↗ tăng 12%', color: Colors.blue),
                _StatCard(title: 'HỒ SƠ MỚI', value: '856', sub: '204 hôm nay', color: Colors.orange),
                _StatCard(title: 'ĐÃ PHỎNG VẤN', value: '18', sub: 'Tháng này', color: Colors.green),
                _StatCard(title: 'CHỜ PHỎNG VẤN', value: '42', sub: '! Cần xử lý', color: Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Ứng viên mới nhất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kNavy)),
            const SizedBox(height: 15),
            _CandidateItem(name: 'Alexandra Chen', role: 'Senior UI Designer', match: '98%'),
            _CandidateItem(name: 'Julian Blackwood', role: 'Product Manager', match: '85%'),
          ],
        ),
      ),
    );
  }
}

// --- TRANG 2: JOBS (Tin tuyển dụng - Hình 2) ---
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
                const Text('Quản lý Tin tuyển dụng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _kNavy)),
                CircleAvatar(backgroundColor: _kGreenAccent, radius: 18, child: const Icon(Icons.person, color: Colors.white, size: 20)),
              ],
            ),
          ),
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
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

// --- TRANG 3: INTERVIEWS (Phỏng vấn - Hình 4) ---
class _InterviewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lịch phỏng vấn', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _kNavy)),
            const Text('Bạn có 3 cuộc phỏng vấn hôm nay', style: TextStyle(color: _kTextSub)),
            const SizedBox(height: 25),
            // Calendar Strip (Simplified)
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
            _InterviewCard(time: '09:00 - 10:00', name: 'Alexander Sterling', role: 'Senior Product Architect', status: 'ĐANG DIỄN RA', isOnline: true),
            _InterviewCard(time: '13:30 - 14:30', name: 'Minh Anh Nguyễn', role: 'Lead DevOps Engineer', status: 'SẮP TỚI', isOnline: false),
          ],
        ),
      ),
    );
  }
}

// --- TRANG 4: TALENT (Nguồn nhân tài - Hình 1) ---
class _TalentSourcePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tuyền tập\nNhân tài Ưu tú', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _kNavy)),
            const SizedBox(height: 20),
            _TalentCard(name: 'Marcus Holloway', role: 'Kiến trúc sư Điện toán Đám mây', experience: '12 Năm', salary: '$185k - $210k'),
            _TalentCard(name: 'Elena Rodriguez', role: 'Giám đốc Kỹ thuật (VP)', experience: '15 Năm', salary: '$230k - $260k'),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS HỖ TRỢ ---

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
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kTextSub)),
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
          CircleAvatar(backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, color: _kNavy)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(role, style: const TextStyle(fontSize: 12, color: _kTextSub))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _kGreenAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(match, style: const TextStyle(color: _kGreenAccent, fontWeight: FontWeight.bold, fontSize: 12))),
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
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: const Text('ĐANG TUYỂN', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))),
              const Icon(Icons.more_vert, color: _kTextSub),
            ],
          ),
          const SizedBox(height: 10),
          Text(job.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _kNavy)),
          const SizedBox(height: 5),
          Row(children: [const Icon(Icons.calendar_today, size: 14, color: _kTextSub), const SizedBox(width: 5), const Text('Đăng: 12/10/2023', style: TextStyle(color: _kTextSub, fontSize: 12)), const SizedBox(width: 15), const Icon(Icons.group_outlined, size: 16, color: _kTextSub), const SizedBox(width: 5), const Text('42 Ứng viên', style: TextStyle(color: _kTextSub, fontSize: 12))]),
          const SizedBox(height: 20),
          Row(children: [Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: _kBg, elevation: 0), child: const Text('Xem chi tiết', style: TextStyle(color: _kNavy)))), const SizedBox(width: 10), Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: _kBg, elevation: 0), child: const Text('Chỉnh sửa', style: TextStyle(color: _kNavy))))]),
        ],
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  final String time, name, role, status;
  final bool isOnline;
  const _InterviewCard({required this.time, required this.name, required this.role, required this.status, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border(left: BorderSide(color: status == 'ĐANG DIỄN RA' ? Colors.green : Colors.orange, width: 4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: status == 'ĐANG DIỄN RA' ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(5)), child: Text(status, style: TextStyle(color: status == 'ĐANG DIỄN RA' ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 15),
          Row(children: [CircleAvatar(radius: 20, backgroundColor: Colors.grey.shade100, child: const Icon(Icons.person)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(role, style: const TextStyle(fontSize: 13, color: _kTextSub))]))]),
          const SizedBox(height: 15),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _kBg, borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(isOnline ? Icons.video_camera_back_outlined : Icons.business_outlined, size: 20, color: _kNavy), const SizedBox(width: 10), Text(isOnline ? 'Google Meet' : 'Văn phòng (P. 402)', style: const TextStyle(fontWeight: FontWeight.w600))])),
          const SizedBox(height: 15),
          Row(children: [Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: _kGreenAccent), child: const Text('Tham gia', style: TextStyle(color: Colors.white)))), const SizedBox(width: 10), Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Xem hồ sơ')))]),
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
          Row(children: [CircleAvatar(radius: 25, backgroundColor: Colors.grey.shade200), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: _kNavy)), Text(role, style: const TextStyle(color: _kTextSub, fontSize: 13))]))]),
          const SizedBox(height: 20),
          const Text('NĂNG LỰC CỐT LÕI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _kTextSub)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ['AWS', 'Kubernetes', 'Python'].map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 10)), backgroundColor: _kBg, side: BorderSide.none)).toList()),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('KINH NGHIỆM', style: TextStyle(fontSize: 10, color: _kTextSub)), Text(experience, style: const TextStyle(fontWeight: FontWeight.bold))]), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('MONG MUỐN', style: TextStyle(fontSize: 10, color: _kTextSub)), Text(salary, style: const TextStyle(fontWeight: FontWeight.bold))])]),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: _kBg, elevation: 0), child: const Text('Xem hồ sơ đầy đủ', style: TextStyle(color: _kNavy)))),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _TabChip({required this.label, required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: isActive ? _kNavy : Colors.white, borderRadius: BorderRadius.circular(12)), child: Text(label, style: TextStyle(color: isActive ? Colors.white : _kNavy, fontWeight: FontWeight.bold, fontSize: 13)));
  }
}

class _DateNode extends StatelessWidget {
  final String day, date;
  final bool isSelected;
  const _DateNode({required this.day, required this.date, this.isSelected = false});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isSelected ? _kNavy : Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(children: [Text(day, style: TextStyle(color: isSelected ? Colors.white70 : _kTextSub, fontSize: 10)), Text(date, style: TextStyle(color: isSelected ? Colors.white : _kNavy, fontSize: 18, fontWeight: FontWeight.bold))]));
  }
}
