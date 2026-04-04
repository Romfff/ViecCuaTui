import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';
import '../profile/profile_screen.dart';
import 'job_detail_screen.dart';

const _kBg = Color(0xFFF8F9FB);
const _kNavy = Color(0xFF0D1B4B);
const _kAccent = Color(0xFF43E8D8); // Màu Xanh Ngọc mới
const _kTextSec = Color(0xFF8E8E93);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _activeFilter = 'Tất cả';
  final _searchController = TextEditingController();
  final _suggestedScrollController = ScrollController();

  final List<String> _keywords = [
    'Java', 'ReactJS', '.NET', 'Tester', 'PHP', 'Business Analysis', 'NodeJS', 'Agile', 'DevOps', 'Cloud'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _suggestedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobProv = context.watch<JobProvider>();

    final List<Widget> pages = [
      _buildHomeContent(auth, jobProv),
      const Center(child: Text('Trang Ứng Tuyển', style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold))),
      const Center(child: Text('Trang Đã Lưu', style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold))),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: _kBg,
      body: pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0 && auth.role == 'job_poster'
          ? FloatingActionButton(
              backgroundColor: _kAccent, // Đổi màu nút nổi
              child: const Icon(Icons.add, color: _kNavy),
              onPressed: () => _showCreateJobDialog(context, auth, jobProv),
            )
          : null,
    );
  }

  Widget _buildHomeContent(AuthProvider auth, JobProvider jobProv) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(auth),
            _buildSearchBar(jobProv),
            _buildKeywords(jobProv),
            _buildSectionHeader('Gợi ý công việc'),
            _buildSuggestedJobs(jobProv.jobs),
            _buildFilterChips(),
            _buildSectionHeader('Việc làm mới nhất'),
            _buildLatestJobs(jobProv),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    final name = auth.user?.email?.split('@').first ?? 'Khách';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 3),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(color: _kNavy, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CHÀO MỪNG TRỞ LẠI', style: TextStyle(fontSize: 10, color: _kTextSec, fontWeight: FontWeight.bold)),
                Text('Chào $name 👋', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _kNavy)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: const Icon(Icons.notifications_none_rounded, color: _kNavy, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(JobProvider prov) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))]),
        child: TextField(
          controller: _searchController,
          onChanged: prov.setSearchTerm,
          decoration: const InputDecoration(hintText: 'Tìm kiếm công việc, công ty...', hintStyle: TextStyle(color: Colors.grey, fontSize: 14), prefixIcon: Icon(Icons.search_rounded, color: Colors.grey), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 15)),
        ),
      ),
    );
  }

  Widget _buildKeywords(JobProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('GỢI Ý TỪ KHÓA', style: TextStyle(fontSize: 10, color: _kTextSec, fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _keywords.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final keyword = _keywords[index];
              return GestureDetector(
                onTap: () {
                  prov.setSearchTerm(keyword);
                  _searchController.text = keyword;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(keyword, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _kNavy)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _kNavy)),
          const Text('Xem tất cả', style: TextStyle(fontSize: 13, color: _kAccent, fontWeight: FontWeight.bold)), // Đổi màu
        ],
      ),
    );
  }

  Widget _buildSuggestedJobs(List<JobModel> jobs) {
    final count = jobs.length > 5 ? 5 : jobs.length;
    return SizedBox(
      height: 230,
      child: Scrollbar(
        controller: _suggestedScrollController,
        thumbVisibility: true,
        child: ListView.separated(
          controller: _suggestedScrollController,
          shrinkWrap: true,
          primary: false,
          dragStartBehavior: DragStartBehavior.start,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.only(left: 20, right: 8),
          scrollDirection: Axis.horizontal,
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) => _SuggestedJobCard(job: jobs[index]),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tất cả', 'Toàn thời gian', 'Bán thời gian'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: filters.map((f) {
          final isSel = _activeFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(color: isSel ? _kAccent : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [if (!isSel) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
              child: Text(f, style: TextStyle(color: isSel ? _kNavy : _kNavy, fontWeight: FontWeight.bold, fontSize: 13)), // Đổi màu text nút active
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLatestJobs(JobProvider prov) {
    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    final jobs = prov.jobs;
    return ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: jobs.length, itemBuilder: (context, index) => _LatestJobCard(job: jobs[index]));
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _kAccent, // Đổi màu menu đang chọn
        unselectedItemColor: _kTextSec,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'KHÁM PHÁ'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'ỨNG TUYỂN'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'ĐÃ LƯU'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'HỒ SƠ'),
        ],
      ),
    );
  }

  void _showCreateJobDialog(BuildContext context, AuthProvider auth, JobProvider jobProv) {
    final titleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();
    final typeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng tin tuyển dụng'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề')),
            TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Công ty')),
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Địa điểm')),
            TextField(controller: salaryCtrl, decoration: const InputDecoration(labelText: 'Mức lương')),
            TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Loại')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 3),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
            onPressed: () async {
              final job = JobModel(id: '', title: titleCtrl.text, company: companyCtrl.text, location: locationCtrl.text, salary: salaryCtrl.text, type: typeCtrl.text, description: descCtrl.text, postedDate: 'Mới đăng', posterId: auth.user?.uid ?? '', posterEmail: auth.user?.email ?? '');
              await jobProv.addJob(job);
              Navigator.pop(ctx);
            },
            child: const Text('Đăng', style: TextStyle(color: _kNavy)),
          ),
        ],
      ),
    );
  }
}

class _SuggestedJobCard extends StatelessWidget {
  final JobModel job;
  const _SuggestedJobCard({required this.job});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260, margin: const EdgeInsets.only(right: 16, bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: _kAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(job.company.isNotEmpty ? job.company[0] : '?', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kAccent)))),
            Row(children: [_Badge(text: 'HOT', color: Colors.red.shade100, textColor: Colors.red), const SizedBox(width: 4), _Badge(text: 'GẤP', color: Colors.orange.shade100, textColor: Colors.orange)])
          ]),
          const SizedBox(height: 12),
          Text(job.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _kNavy), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(job.company, style: const TextStyle(color: _kTextSec, fontSize: 12)),
          const Spacer(),
          Row(children: [const Icon(Icons.payments_outlined, size: 14, color: _kAccent), const SizedBox(width: 4), Text(job.salary, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _kNavy))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: _kAccent), const SizedBox(width: 4), Text(job.location, style: const TextStyle(fontSize: 12, color: _kTextSec))]),
          const SizedBox(height: 8),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['Java', 'Spring Boot', 'AWS'].map((s) => Container(margin: const EdgeInsets.only(right: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)), child: Text(s, style: const TextStyle(fontSize: 10, color: _kNavy)))).toList()))
        ],
      ),
    );
  }
}

class _LatestJobCard extends StatelessWidget {
  final JobModel job;
  const _LatestJobCard({required this.job});
  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final jobProv = context.read<JobProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: _kAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(job.company.isNotEmpty ? job.company[0] : '?', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _kAccent)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(job.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _kNavy)), Text(job.company, style: const TextStyle(color: _kTextSec, fontSize: 12))])),
            IconButton(icon: const Icon(Icons.bookmark_outline, color: _kTextSec), onPressed: () {}),
            if (auth.user?.uid == job.posterId) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => jobProv.removeJob(job.id)),
          ]),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.payments_outlined, size: 16, color: _kAccent), const SizedBox(width: 4), Text(job.salary, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _kNavy)), const SizedBox(width: 16), const Icon(Icons.location_on_outlined, size: 16, color: _kAccent), const SizedBox(width: 4), Expanded(child: Text(job.location, style: const TextStyle(fontSize: 13, color: _kNavy), overflow: TextOverflow.ellipsis))]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _kAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('MỚI ĐĂNG', style: TextStyle(color: _kAccent, fontSize: 11, fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(job: job))),
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent, foregroundColor: _kNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), elevation: 0),
              child: const Text('Ứng tuyển nhanh', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ])
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text; final Color color; final Color textColor;
  const _Badge({required this.text, required this.color, required this.textColor});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)), child: Text(text, style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.bold)));
  }
}
