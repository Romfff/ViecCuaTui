import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/job_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/job_provider.dart';
import '../profile/profile_screen.dart';
import 'job_detail_screen.dart';

const _cNavy = Color(0xFF0D1B4B);
const _cTurquoise = Color(0xFF43E8D8);
const _cTurquoiseDim = Color(0xFF2DD4BF);
const _cBg = Color(0xFFF8F9FA);
const _cSurface = Color(0xFFFFFFFF);
const _cTextPrimary = Color(0xFF0D1B4B);
const _cTextSub = Color(0xFF6B7280);
const _cInputFill = Color(0xFFF3F4F6);
const _cCardRadius = 16.0;

const _kSoftShadow = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 12,
  offset: Offset(0, 4),
);

const _kFilters = ['Tất cả', 'Full-time', 'Part-time', 'Remote', 'Intern'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _activeFilter = 'Tất cả';

  List<JobModel> _applyFilter(List<JobModel> jobs) {
    if (_activeFilter == 'Tất cả') return jobs;
    return jobs
        .where((j) => j.type.toLowerCase().contains(_activeFilter.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final jobProv = context.watch<JobProvider>();
    final filtered = _applyFilter(jobProv.jobs);

    return Scaffold(
      backgroundColor: _cBg,
      floatingActionButton: auth.role == 'job_poster'
          ? FloatingActionButton.extended(
              backgroundColor: _cTurquoise,
              foregroundColor: _cNavy,
              elevation: 2,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Đăng tin', style: TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () => _showCreateJobDialog(context, auth, jobProv),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          _CustomSliverAppBar(auth: auth),
          SliverToBoxAdapter(
            child: _FilterSection(
              activeFilter: _activeFilter,
              onFilterChanged: (f) => setState(() => _activeFilter = f),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  const Text(
                    'Việc làm dành cho bạn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _cTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (!jobProv.isLoading && !jobProv.hasError)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _cTurquoise.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${filtered.length} việc',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _cTurquoiseDim,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _buildBody(jobProv, filtered),
        ],
      ),
    );
  }

  Widget _buildBody(JobProvider jobProv, List<JobModel> filtered) {
    if (jobProv.isLoading) {
      return const SliverFillRemaining(hasScrollBody: false, child: _LoadingState());
    }
    if (jobProv.hasError) {
      return const SliverFillRemaining(hasScrollBody: false, child: _ErrorState());
    }
    if (filtered.isEmpty) {
      return const SliverFillRemaining(hasScrollBody: false, child: _EmptyState());
    }
    return _JobListView(filtered: filtered);
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
        backgroundColor: _cSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Đăng tin tuyển dụng',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _cNavy),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(ctrl: titleCtrl, label: 'Tiêu đề', icon: Icons.title_rounded),
              const SizedBox(height: 10),
              _DialogField(ctrl: companyCtrl, label: 'Công ty', icon: Icons.business_rounded),
              const SizedBox(height: 10),
              _DialogField(ctrl: locationCtrl, label: 'Địa điểm', icon: Icons.location_on_outlined),
              const SizedBox(height: 10),
              _DialogField(ctrl: salaryCtrl, label: 'Mức lương', icon: Icons.attach_money_rounded),
              const SizedBox(height: 10),
              _DialogField(ctrl: typeCtrl, label: 'Loại công việc', icon: Icons.work_outline_rounded),
              const SizedBox(height: 10),
              _DialogField(ctrl: descCtrl, label: 'Mô tả', icon: Icons.description_outlined, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: _cTextSub)),
          ),
          GestureDetector(
            onTap: () async {
              final job = JobModel(
                id: '',
                title: titleCtrl.text.trim(),
                company: companyCtrl.text.trim(),
                location: locationCtrl.text.trim(),
                salary: salaryCtrl.text.trim(),
                type: typeCtrl.text.trim(),
                description: descCtrl.text.trim(),
                postedDate: 'Mới đăng',
                posterId: auth.user?.uid ?? '',
                posterEmail: auth.user?.email ?? '',
              );
              await jobProv.addJob(job);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_cTurquoise, _cTurquoiseDim]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Đăng tin',
                style: TextStyle(color: _cNavy, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _CustomSliverAppBar extends StatelessWidget {
  final AuthProvider auth;

  const _CustomSliverAppBar({required this.auth});

  String get _displayName {
    final email = auth.user?.email ?? '';
    if (email.isEmpty) return 'bạn';
    return email.split('@').first;
  }

  String get _initial {
    final n = _displayName;
    return n.isNotEmpty ? n[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 132,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: _cSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Hi, $_displayName',
        style: const TextStyle(
          color: _cNavy,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: _NavyAvatar(initial: _initial, size: 36, fontSize: 14),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          color: _cSurface,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, $_displayName 👋',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: _cNavy,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tìm công việc phù hợp với bạn',
                              style: TextStyle(fontSize: 13, color: _cTextSub),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                        child: _NavyAvatar(initial: _initial, size: 48, fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFF3F4F6)),
      ),
    );
  }
}

class _NavyAvatar extends StatelessWidget {
  final String initial;
  final double size;
  final double fontSize;

  const _NavyAvatar({required this.initial, required this.size, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _cNavy.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(color: _cNavy.withOpacity(0.14), width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: _cNavy,
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  const _FilterSection({required this.activeFilter, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _kFilters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final filter = _kFilters[index];
            final isActive = filter == activeFilter;
            return GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? _cNavy : _cInputFill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isActive ? Colors.white : _cTextSub,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _JobListView extends StatelessWidget {
  final List<JobModel> filtered;

  const _JobListView({required this.filtered});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: EdgeInsets.only(bottom: index < filtered.length - 1 ? 12 : 0),
            child: _JobCard(
              job: filtered[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => JobDetailScreen(job: filtered[index])),
              ),
            ),
          ),
          childCount: filtered.length,
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.onTap});

  Color _logoColor() {
    const palette = [
      Color(0xFF4F46E5),
      Color(0xFF0891B2),
      Color(0xFF059669),
      Color(0xFFD97706),
      Color(0xFFDC2626),
      Color(0xFF7C3AED),
    ];
    final idx = job.company.isEmpty ? 0 : job.company.codeUnitAt(0) % palette.length;
    return palette[idx];
  }

  @override
  Widget build(BuildContext context) {
    final color = _logoColor();
    final initial = job.company.isNotEmpty ? job.company[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: _cSurface,
          borderRadius: BorderRadius.all(Radius.circular(_cCardRadius)),
          boxShadow: [_kSoftShadow],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CompanyLogo(initial: initial, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title.isEmpty ? '—' : job.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _cTextPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    job.company.isEmpty ? '—' : job.company,
                    style: const TextStyle(fontSize: 13, color: _cTextSub, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ApplyButton(onTap: onTap),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (job.salary.isNotEmpty) ...[
                                _Badge(
                                  icon: Icons.attach_money_rounded,
                                  text: job.salary,
                                  bgColor: _cTurquoise.withOpacity(0.10),
                                  textColor: _cTurquoiseDim,
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (job.location.isNotEmpty)
                                _Badge(
                                  icon: Icons.location_on_outlined,
                                  text: job.location,
                                  bgColor: _cInputFill,
                                  textColor: _cTextSub,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String initial;
  final Color color;

  const _CompanyLogo({required this.initial, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.14), width: 1),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
        ),
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ApplyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_cTurquoise, _cTurquoiseDim],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Ứng tuyển',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _cNavy),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bgColor;
  final Color textColor;

  const _Badge({required this.icon, required this.text, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 3),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final int maxLines;

  const _DialogField({required this.ctrl, required this.label, required this.icon, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _cTextSub, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: _cTextSub),
        filled: true,
        fillColor: _cInputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: _cTurquoise, width: 1.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _cTurquoise, strokeWidth: 3),
          SizedBox(height: 16),
          Text('Đang tải...', style: TextStyle(color: _cTextSub, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.wifi_off_rounded, size: 36, color: Colors.red.shade300),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải dữ liệu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _cTextPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng kiểm tra kết nối mạng và thử lại.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _cTextSub),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _cTurquoise.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 40, color: _cTurquoise),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy công việc',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _cTextPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thử thay đổi bộ lọc để xem thêm kết quả.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _cTextSub),
            ),
          ],
        ),
      ),
    );
  }
}