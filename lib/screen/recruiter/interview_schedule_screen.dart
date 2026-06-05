import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/interview_model.dart';
import '../../provider/interview_provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/custom_button.dart';

const _kNavy = Color(0xFF0D1B4B);
const _kGreenAccent = Color(0xFF0FB488);
const _kBg = Color(0xFFF8F9FB);
const _kTextSub = Color(0xFF8E8E93);

class InterviewScheduleScreen extends StatefulWidget {
  final DateTime? initialDate;

  const InterviewScheduleScreen({
    super.key,
    this.initialDate,
  });

  @override
  State<InterviewScheduleScreen> createState() => _InterviewScheduleScreenState();
}

class _InterviewScheduleScreenState extends State<InterviewScheduleScreen> {
  late DateTime _focusedDate;
  late ScrollController _scrollController;
  late final DateTime _startDate;
  late final List<DateTime> _scrollableDays;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate ?? DateTime.now();
    
    final today = DateTime.now();
    final todayClean = DateTime(today.year, today.month, today.day);
    _startDate = todayClean.subtract(const Duration(days: 90));
    _scrollableDays = List.generate(90 + 730 + 1, (index) => _startDate.add(Duration(days: index)));
    
    final initialIndex = _focusedDate.difference(_startDate).inDays;
    final itemWidth = 65.0 + 12.0; // container width (65) + margin right (12)
    final initialOffset = (initialIndex * itemWidth - 100.0).clamp(0.0, double.infinity);
    _scrollController = ScrollController(initialScrollOffset: initialOffset);

    // Listen to recruiter interviews with actual recruiter ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<InterviewProvider>().listenRecruiterInterviews(authProvider.user!.uid);
      }
    });
  }

  void _scrollToFocusedDate({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final index = _focusedDate.difference(_startDate).inDays;
    final itemWidth = 65.0 + 12.0;
    final targetOffset = (index * itemWidth - 100.0).clamp(0.0, _scrollController.position.maxScrollExtent);
    if (animate) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(targetOffset);
    }
  }

  void _selectDate(DateTime day) {
    setState(() {
      _focusedDate = day;
    });
    _scrollToFocusedDate();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    // Check if the query is a date pattern like "dd/MM/yyyy" or "dd/MM"
    final dateRegExp = RegExp(r'^(\d{1,2})/(\d{1,2})(/\d{4})?$');
    if (dateRegExp.hasMatch(query.trim())) {
      final match = dateRegExp.firstMatch(query.trim());
      if (match != null) {
        try {
          final day = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final now = DateTime.now();
          int year = now.year;
          if (match.group(3) != null) {
            year = int.parse(match.group(3)!.substring(1));
          }
          final targetDate = DateTime(year, month, day);
          
          if (targetDate.isAfter(_startDate.subtract(const Duration(days: 1))) &&
              targetDate.isBefore(_startDate.add(Duration(days: _scrollableDays.length)))) {
            _selectDate(targetDate);
          }
        } catch (_) {
          // Ignore parse errors
        }
      }
    }
  }

  Future<void> _openQuickDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDate,
      firstDate: _startDate,
      lastDate: _startDate.add(Duration(days: _scrollableDays.length - 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kNavy,
              onPrimary: Colors.white,
              onSurface: _kNavy,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _kGreenAccent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _selectDate(picked);
      _searchController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {
        _searchQuery = _searchController.text;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  DateTime getMonday(DateTime date) {
    int difference = date.weekday - 1;
    return date.subtract(Duration(days: difference));
  }

  List<DateTime> getWeekDays(DateTime mondayDate) {
    return List.generate(7, (index) => mondayDate.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kNavy),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lịch Phỏng Vấn',
          style: TextStyle(
            color: _kNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<InterviewProvider>(
        builder: (context, interviewProvider, _) {
          final interviews = interviewProvider.recruiterInterviews;
          
          // Filter interviews for the selected day and search query
          final filteredInterviews = interviews.where((interview) {
            try {
              final parts = interview.interviewTime.split(' - ');
              final dateParts = parts[0].split('/');
              final day = int.parse(dateParts[0]);
              final month = int.parse(dateParts[1]);
              final year = int.parse(dateParts[2]);
              
              final interviewDate = DateTime(year, month, day);
              final matchesDate = interviewDate.day == _focusedDate.day &&
                  interviewDate.month == _focusedDate.month &&
                  interviewDate.year == _focusedDate.year;
                  
              if (_searchQuery.isEmpty) return matchesDate;
              
              final queryLower = _searchQuery.toLowerCase();
              
              // If query matches current selected date formatting, don't filter candidate names out
              if (queryLower == '${_focusedDate.day.toString().padLeft(2, '0')}/${_focusedDate.month.toString().padLeft(2, '0')}/${_focusedDate.year}') {
                return matchesDate;
              }
              
              final matchesSearch = interview.candidateName.toLowerCase().contains(queryLower) ||
                  interview.candidateRole.toLowerCase().contains(queryLower);
              
              return matchesDate && matchesSearch;
            } catch (e) {
              return false;
            }
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Week navigation and day selector
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title subtitle
                      Text(
                        _isToday(_focusedDate)
                            ? 'Bạn có ${interviews.where((i) {
                                try {
                                  final parts = i.interviewTime.split(' - ');
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
                              }).length} cuộc phỏng vấn hôm nay'
                            : 'Bạn có ${interviews.where((i) {
                                try {
                                  final parts = i.interviewTime.split(' - ');
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
                              }).length} cuộc phỏng vấn ngày ${_focusedDate.day.toString().padLeft(2, '0')}/${_focusedDate.month.toString().padLeft(2, '0')}/${_focusedDate.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _kTextSub,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: _kNavy, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: const InputDecoration(
                                  hintText: 'Tìm ngày (ngày/tháng/năm) hoặc ứng viên...',
                                  hintStyle: TextStyle(color: _kTextSub, fontSize: 13),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, color: _kTextSub, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            IconButton(
                              icon: const Icon(Icons.calendar_month, color: _kGreenAccent, size: 22),
                              onPressed: () => _openQuickDatePicker(context),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.only(left: 8, top: 10, bottom: 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tháng ${_focusedDate.month}, ${_focusedDate.year}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _kNavy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Day picker - scrollable up to 2 years
                      SizedBox(
                        height: 80,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                            },
                          ),
                          child: ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _scrollableDays.length,
                            itemBuilder: (context, index) {
                              final day = _scrollableDays[index];
                              final isSelected = _focusedDate.day == day.day &&
                                  _focusedDate.month == day.month &&
                                  _focusedDate.year == day.year;
                              
                              return GestureDetector(
                                onTap: () => _selectDate(day),
                                child: Container(
                                  width: 65,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? _kNavy : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      if (!isSelected)
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'TH ${day.weekday}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : _kTextSub,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        day.day.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : _kNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Interviews list for selected day
                if (filteredInterviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today, color: _kTextSub, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có cuộc phỏng vấn',
                          style: TextStyle(
                            color: _kNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_focusedDate.day}/${_focusedDate.month}/${_focusedDate.year}',
                          style: const TextStyle(
                            color: _kTextSub,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...filteredInterviews
                            .map((interview) => _buildInterviewCard(context, interview))
                            .toList(),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInterviewCard(BuildContext context, InterviewModel interview) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: interview.status == 'pending' ? Colors.orange : _kGreenAccent,
            width: 4,
          ),
        ),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: const Icon(Icons.person, color: _kNavy, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      interview.candidateName,
                      style: const TextStyle(
                        color: _kNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      interview.candidateRole,
                      style: const TextStyle(
                        color: _kTextSub,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: interview.status == 'pending'
                      ? Colors.orange.withOpacity(0.2)
                      : _kGreenAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  interview.status == 'pending' ? 'SẮP TỚI' : 'HOÀN THÀNH',
                  style: TextStyle(
                    color: interview.status == 'pending' ? Colors.orange : _kGreenAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.schedule, color: _kGreenAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                interview.interviewTime,
                style: const TextStyle(
                  color: _kNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (interview.interviewType == 'meet') ...[
            Row(
              children: [
                Icon(Icons.video_call, color: _kGreenAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Google Meet',
                    style: const TextStyle(
                      color: _kTextSub,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.location_on, color: _kGreenAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    interview.officeAddress ?? 'Tại Văn Phòng',
                    style: const TextStyle(
                      color: _kTextSub,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (interview.interviewType == 'meet') ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Mở Meet',
                    icon: Icons.video_call,
                    onPressed: () {
                      // TODO: Open Google Meet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đang mở Google Meet...')),
                      );
                    },
                    enabledColor: _kGreenAccent,
                    isFullWidth: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomOutlinedButton(
                    label: 'Dán link',
                    icon: Icons.link,
                    onPressed: () => _showPasteMeetLinkDialog(context, interview),
                    borderColor: _kGreenAccent,
                    textColor: _kGreenAccent,
                    isFullWidth: false,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showPasteMeetLinkDialog(BuildContext context, InterviewModel interview) {
    final TextEditingController linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dán Google Meet Link'),
        content: TextField(
          controller: linkController,
          decoration: InputDecoration(
            hintText: 'Nhập Google Meet link',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (linkController.text.isNotEmpty) {
                // TODO: Update interview with meet link
                context.read<InterviewProvider>().updateMeetLink(
                  interview.id,
                  linkController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã cập nhật Google Meet link'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreenAccent,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
