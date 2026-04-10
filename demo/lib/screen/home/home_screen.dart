import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';
import '../notifications/notification_screen.dart';
import '../profile/profile_screen.dart';
import 'filtered_job_list_screen.dart';
import 'job_detail_screen.dart';

const _kBg = Color(0xFFF8F9FB);
const _kNavy = Color(0xFF0D1B4B);
const _kAccent = Color(0xFF43E8D8); // Màu Xanh Ngọc mới
const _kTextSec = Color(0xFF8E8E93);

class _DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _activeFilterCategory = 'Địa điểm';
  Timer? _scrollTimer;
  final _searchController = TextEditingController();
  final _keywordScrollController = ScrollController();
  final _suggestedScrollController = ScrollController();

  final Map<String, List<String>> _filterOptions = {
    'Địa điểm': ['Ngẫu nhiên', 'Hà Nội', 'TP HCM', 'Đà Nẵng'],
    'Mức lương': ['Ngẫu nhiên', 'Dưới 10M', '10-20M', 'Trên 20M'],
    'Kinh nghiệm': ['Ngẫu nhiên', 'Mới tốt nghiệp', '1-3 năm', '3-5 năm'],
    'Ngành nghề': ['Ngẫu nhiên', 'IT', 'Marketing', 'Design', 'Sales'],
  };

  final Map<String, String> _selectedFilterOption = {
    'Địa điểm': 'Ngẫu nhiên',
    'Mức lương': 'Ngẫu nhiên',
    'Kinh nghiệm': 'Ngẫu nhiên',
    'Ngành nghề': 'Ngẫu nhiên',
  };

  final List<String> _keywords = [
    'Java',
    'ReactJS',
    '.NET',
    'Tester',
    'PHP',
    'Business Analysis',
    'NodeJS',
    'Agile',
    'DevOps',
    'Cloud',
  ];

  @override
  void initState() {
    super.initState();
    _scrollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _scrollSuggestedJobs(),
    );
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _searchController.dispose();
    _keywordScrollController.dispose();
    _suggestedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobProv = context.watch<JobProvider>();

    final List<Widget> pages = [
      _buildHomeContent(auth, jobProv),
      const Center(
        child: Text(
          'Trang Ứng Tuyển',
          style: TextStyle(color: _kNavy, fontWeight: FontWeight.bold),
        ),
      ),
      _buildSavedJobs(auth, jobProv),
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
            _buildFilterChips(jobProv),
            _buildKeywords(jobProv),
            _buildSectionHeader('Gợi ý công việc'),
            _buildSuggestedJobs(jobProv.jobs, jobProv),
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
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHÀO MỪNG TRỞ LẠI',
                  style: TextStyle(
                    fontSize: 10,
                    color: _kTextSec,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Chào $name 👋',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _kNavy,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: _kNavy,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(JobProvider prov) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: prov.setSearchTerm,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm công việc, công ty...',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildKeywords(JobProvider prov) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'GỢI Ý TỪ KHÓA',
            style: TextStyle(
              fontSize: 10,
              color: _kTextSec,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: Listener(
            onPointerSignal: (event) =>
                _handlePointerSignal(event, _keywordScrollController),
            child: ScrollConfiguration(
              behavior: _DesktopScrollBehavior(),
              child: ListView.separated(
                controller: _keywordScrollController,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        keyword,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _kNavy,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _kNavy,
            ),
          ),
          const Text(
            'Xem tất cả',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ), // Đổi màu
        ],
      ),
    );
  }

  Widget _buildSuggestedJobs(List<JobModel> jobs, JobProvider prov) {
    final count = jobs.length > 5 ? 5 : jobs.length;
    return SizedBox(
      height: 250,
      child: ScrollConfiguration(
        behavior: _DesktopScrollBehavior(),
        child: Listener(
          onPointerSignal: (event) =>
              _handlePointerSignal(event, _suggestedScrollController),
          child: Scrollbar(
            controller: _suggestedScrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: _suggestedScrollController,
              shrinkWrap: true,
              primary: false,
              dragStartBehavior: DragStartBehavior.start,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(left: 20, right: 8),
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return GestureDetector(
                  onTap: () => _showFilteredJobList(context, prov, job.title),
                  child: _SuggestedJobCard(job: job),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _scrollSuggestedJobs() {
    if (!_suggestedScrollController.hasClients) return;
    final maxScroll = _suggestedScrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    const offsetStep = 276.0;
    final nextOffset = _suggestedScrollController.offset + offsetStep;
    final target = nextOffset > maxScroll ? 0.0 : nextOffset;
    _suggestedScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _showFilteredJobList(
    BuildContext context,
    JobProvider prov,
    String keyword,
  ) {
    final filteredJobs = prov.filterJobs(keyword);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FilteredJobListScreen(title: keyword, jobs: filteredJobs),
      ),
    );
  }

  void _handlePointerSignal(
    PointerSignalEvent event,
    ScrollController controller,
  ) {
    if (event is PointerScrollEvent && controller.hasClients) {
      final newOffset = controller.offset + event.scrollDelta.dy;
      final target = newOffset.clamp(0.0, controller.position.maxScrollExtent);
      controller.jumpTo(target);
    }
  }

  Widget _buildFilterChips(JobProvider prov) {
    final categories = _filterOptions.keys.toList();
    final activeOptions = _filterOptions[_activeFilterCategory]!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScrollConfiguration(
            behavior: _DesktopScrollBehavior(),
            child: SizedBox(
              height: 56,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: categories.map((category) {
                    final isSelected = category == _activeFilterCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _activeFilterCategory = category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _kAccent.withOpacity(0.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? _kAccent
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ScrollConfiguration(
            behavior: _DesktopScrollBehavior(),
            child: SizedBox(
              height: 42,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: activeOptions.map((option) {
                    final isSelected =
                        _selectedFilterOption[_activeFilterCategory] == option;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ActionChip(
                        label: Text(option),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                        backgroundColor: isSelected
                            ? _kAccent
                            : const Color(0xFFF1F4F8),
                        onPressed: () {
                          setState(() {
                            _selectedFilterOption[_activeFilterCategory] =
                                option;
                          });
                          prov.setSearchTerm(
                            option == 'Ngẫu nhiên' ? '' : option,
                          );
                          _searchController.text = option == 'Ngẫu nhiên'
                              ? ''
                              : option;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestJobs(JobProvider prov) {
    if (prov.isLoading) return const Center(child: CircularProgressIndicator());
    final jobs = prov.jobs;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _LatestJobCard(job: jobs[index]),
    );
  }

  Widget _buildSavedJobs(AuthProvider auth, JobProvider jobProv) {
    if (auth.user == null) {
      return const Center(
        child: Text('Vui lòng đăng nhập để xem công việc đã lưu'),
      );
    }
    final savedJobs = jobProv.getBookmarkedJobs(auth.bookmarkedJobIds);
    if (savedJobs.isEmpty) {
      return const Center(child: Text('Chưa có công việc nào được lưu'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: savedJobs.length,
      itemBuilder: (context, index) => _LatestJobCard(job: savedJobs[index]),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _kAccent, // Đổi màu menu đang chọn
        unselectedItemColor: _kTextSec,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'KHÁM PHÁ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'ỨNG TUYỂN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'ĐÃ LƯU',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'HỒ SƠ',
          ),
        ],
      ),
    );
  }

  void _showCreateJobDialog(
    BuildContext context,
    AuthProvider auth,
    JobProvider jobProv,
  ) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(labelText: 'Công ty'),
              ),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: 'Địa điểm'),
              ),
              TextField(
                controller: salaryCtrl,
                decoration: const InputDecoration(labelText: 'Mức lương'),
              ),
              TextField(
                controller: typeCtrl,
                decoration: const InputDecoration(labelText: 'Loại'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
            onPressed: () async {
              final job = JobModel(
                id: '',
                title: titleCtrl.text,
                company: companyCtrl.text,
                location: locationCtrl.text,
                salary: salaryCtrl.text,
                type: typeCtrl.text,
                description: descCtrl.text,
                postedDate: 'Mới đăng',
                posterId: auth.user?.uid ?? '',
                posterEmail: auth.user?.email ?? '',
              );
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
    final auth = context.watch<AuthProvider>();
    final isBookmarked = auth.bookmarkedJobIds.contains(job.id);
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBookmarked ? _kAccent : _kAccent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _kAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    job.company.isNotEmpty ? job.company[0] : '?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _Badge(
                    text: 'HOT',
                    color: Colors.red.shade100,
                    textColor: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  _Badge(
                    text: 'GẤP',
                    color: Colors.orange.shade100,
                    textColor: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            job.company,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
          if (isBookmarked) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _kAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ĐÃ LƯU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
            ),
          ],
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 16,
                color: Colors.black,
              ),
              const SizedBox(width: 4),
              Text(
                job.salary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.black,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
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
    final auth = context.watch<AuthProvider>();
    final jobProv = context.read<JobProvider>();
    final isBookmarked = auth.bookmarkedJobIds.contains(job.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _kAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    job.company.isNotEmpty ? job.company[0] : '?',
                    style: const TextStyle(
                      fontSize: 24,
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
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: _kNavy,
                      ),
                    ),
                    Text(
                      job.company,
                      style: const TextStyle(color: _kTextSec, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isBookmarked ? _kAccent : _kTextSec,
                ),
                onPressed: () {
                  if (auth.user != null) {
                    auth.toggleBookmark(job.id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng đăng nhập để lưu công việc'),
                      ),
                    );
                  }
                },
              ),
              if (auth.user?.uid == job.posterId)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => jobProv.removeJob(job.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 16, color: _kAccent),
              const SizedBox(width: 4),
              Text(
                job.salary,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.location_on_outlined, size: 16, color: _kAccent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location,
                  style: const TextStyle(fontSize: 13, color: _kNavy),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _kAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'MỚI ĐĂNG',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailScreen(job: job),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccent,
                        foregroundColor: _kNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ứng tuyển nhanh',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  const _Badge({
    required this.text,
    required this.color,
    required this.textColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
