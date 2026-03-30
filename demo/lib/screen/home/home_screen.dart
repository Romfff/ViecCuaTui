import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';
import '../../models/job_model.dart';
import '../../widgets/job_card.dart';
import '../profile/profile_screen.dart';
import 'job_detail_screen.dart';

const Color kPrimary = Color(0xFF43E8D8);
const Color kPrimaryDark = Color(0xFF1EC5B2);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _topEmployersScrollController = ScrollController();

  String _selectedCity = 'All Cities';
  String _keyword = '';

  // Web runtime đôi khi có thể gặp giá trị dynamic/undefined => không gọi trực tiếp .trim() nữa.
  String _safeTrim(dynamic v) {
    if (v == null) return '';
    return v.toString().trim();
  }

  static const List<String> _suggestions = [
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
    'Team Management',
  ];

  @override
  void initState() {
    super.initState();
    // Reset filter để tránh bị "dính" keyword/city cũ khi đổi role hoặc mở lại Home.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchController.clear();
      _keyword = '';
      _selectedCity = 'All Cities';
      context.read<JobProvider>().setSearchTerm('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _topEmployersScrollController.dispose();
    super.dispose();
  }

  void _syncSearch(JobProvider jobProv) {
    final keyword = _safeTrim(_keyword);
    if (keyword.isNotEmpty) {
      jobProv.setSearchTerm(keyword);
      return;
    }
    if (_selectedCity != 'All Cities') {
      jobProv.setSearchTerm(_selectedCity);
      return;
    }
    jobProv.setSearchTerm('');
  }

  void _openMenu(BuildContext context) {
    final auth = context.read<AuthProvider>();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Hồ sơ'),
                subtitle: Text(auth.user?.email ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: kPrimary),
                title: Text('Đăng xuất', style: TextStyle(color: kPrimary)),
                onTap: () {
                  auth.logout();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _AppLogo({required String title}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.16),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
          ),
          child: Icon(Icons.work_outline, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              colors: [Colors.white, Colors.white70],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(rect);
          },
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobProv = context.watch<JobProvider>();
    final jobs = jobProv.jobs;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: kPrimary.withOpacity(0.06),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryDark, kPrimary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () => _openMenu(context),
                  ),
                  Expanded(
                    child: Center(
                      child: _AppLogo(title: 'ViecCuaTui'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tìm việc làm',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            _safeTrim(_keyword).isNotEmpty
                                ? '${jobs.length} jobs cho "${_safeTrim(_keyword)}"'
                                : '${jobs.length} jobs',
                            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 12),

                          // City dropdown + keyword search
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCity,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(value: 'All Cities', child: Text('All Cities')),
                                        DropdownMenuItem(value: 'Hà Nội', child: Text('Hà Nội')),
                                        DropdownMenuItem(value: 'Hồ Chí Minh', child: Text('Hồ Chí Minh')),
                                      ],
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() => _selectedCity = v);
                                        _syncSearch(jobProv);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: TextField(
                                            controller: _searchController,
                                            textAlignVertical: TextAlignVertical.center,
                                            onChanged: (value) {
                                              setState(() => _keyword = value);
                                              _syncSearch(jobProv);
                                            },
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.search, color: kPrimary),
                                              hintText: 'Enter keyword skill (Java, IOS...)',
                                              border: InputBorder.none,
                                              // Giúp placeholder/text nằm giữa đúng với height ~52
                                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: kPrimary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.search, color: Colors.white),
                                          onPressed: () => _syncSearch(jobProv),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12),

                          Text(
                            'Gợi ý cho bạn:',
                            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: _suggestions.map((s) {
                              return ActionChip(
                                label: Text(s),
                                backgroundColor: Colors.white,
                                shape: StadiumBorder(
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _keyword = s;
                                    _selectedCity = 'All Cities';
                                    _searchController.text = s;
                                  });
                                  jobProv.setSearchTerm(s);
                                },
                              );
                            }).toList(),
                          ),

                          SizedBox(height: 18),
                          _buildTopEmployers(jobs: jobs),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),

                    if (jobProv.isLoading)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (jobs.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'Không tìm thấy công việc phù hợp',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => JobCardItem(
                            job: jobs[index],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailScreen(job: jobs[index]),
                              ),
                            ),
                          ),
                          childCount: jobs.length,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: auth.role == 'job_poster'
          ? FloatingActionButton.extended(
              icon: Icon(Icons.add),
              label: Text('Đăng tin'),
              onPressed: () => _showCreateJobDialog(context),
            )
          : null,
    );
  }

  Widget _buildTopEmployers({required List<JobModel> jobs}) {
    if (jobs.isEmpty) return SizedBox.shrink();

    final counts = <String, int>{};
    for (final j in jobs) {
      final key = _safeTrim(j.company);
      if (key.isEmpty) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final sortedCompanies = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = sortedCompanies.take(4).toList();
    if (top.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Employers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 230, // tránh overflow khi nội dung chip/badge cao
          child: Scrollbar(
            controller: _topEmployersScrollController,
            thumbVisibility: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                try {
                  final max = _topEmployersScrollController.position.maxScrollExtent;
                  final next = (_topEmployersScrollController.offset - details.delta.dx).clamp(0.0, max);
                  _topEmployersScrollController.jumpTo(next);
                } catch (_) {
                  // Có thể chưa attach controller, bỏ qua.
                }
              },
              child: ListView.separated(
                controller: _topEmployersScrollController,
                scrollDirection: Axis.horizontal,
                primary: false,
                physics: const ClampingScrollPhysics(),
                itemCount: top.length,
                separatorBuilder: (_, __) => SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final companyName = top[index].key;
                  final jobCount = top[index].value;
                  final companyJobs = jobs.where((e) => _safeTrim(e.company) == companyName).toList();
                  final location = companyJobs.isNotEmpty ? companyJobs.first.location : '';

                  final tagSet = <String>{};
                  for (final j in companyJobs) {
                    final t = _safeTrim(j.type);
                    if (t.isEmpty) continue;
                    tagSet.add(t);
                  }
                  final tags = tagSet.take(4).toList();

                  final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : '?';
                  return TopEmployerCard(
                    companyName: companyName,
                    jobCount: jobCount,
                    location: location,
                    tags: tags,
                    onTap: null,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateJobDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final locationController = TextEditingController();
    final salaryController = TextEditingController();
    final typeController = TextEditingController();
    final descriptionController = TextEditingController();

    if (auth.role != 'job_poster') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chỉ người đăng việc mới có quyền đăng tin.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm công việc mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: 'Tiêu đề')),
              TextField(controller: companyController, decoration: InputDecoration(labelText: 'Công ty')),
              TextField(controller: locationController, decoration: InputDecoration(labelText: 'Địa điểm')),
              TextField(controller: salaryController, decoration: InputDecoration(labelText: 'Lương')),
              TextField(controller: typeController, decoration: InputDecoration(labelText: 'Loại công việc')),
              TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Mô tả'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final jobProv = context.read<JobProvider>();
              final job = JobModel(
                id: '',
                title: titleController.text.trim(),
                company: companyController.text.trim(),
                location: locationController.text.trim(),
                salary: salaryController.text.trim(),
                type: typeController.text.trim(),
                description: descriptionController.text.trim(),
                postedDate: 'Mới đăng',
                posterId: auth.user?.uid ?? '',
                posterEmail: auth.user?.email ?? '',
              );
              await jobProv.addJob(job);
              Navigator.pop(context);
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }
}


class JobCardWidget extends StatelessWidget {
  final JobModel job;
  const JobCardWidget({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailScreen(job: job))),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(job.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  Chip(label: Text(job.type, style: TextStyle(color: Colors.white)), backgroundColor: kPrimary),
                ],
              ),
              SizedBox(height: 6),
              Text(job.company, style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(child: Text(job.location, style: TextStyle(color: Colors.grey[700]))),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.monetization_on, size: 16, color: Colors.grey[700]),
                  SizedBox(width: 4),
                  Text(job.salary, style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text(job.postedDate, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
