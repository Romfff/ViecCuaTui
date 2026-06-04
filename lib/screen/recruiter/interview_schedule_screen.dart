import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate ?? DateTime.now();
    // Listen to recruiter interviews with actual recruiter ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user != null) {
        context.read<InterviewProvider>().listenRecruiterInterviews(authProvider.user!.uid);
      }
    });
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
    final weekStart = getMonday(_focusedDate);
    final weekDays = getWeekDays(weekStart);

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
          
          // Filter interviews for the selected day
          final filteredInterviews = interviews.where((interview) {
            // Parse the interview time to get the date
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
                        'Bạn có ${interviews.where((i) {
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
                        }).length} cuộc phỏng vấn hôm nay',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _kTextSub,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Day picker - simplified
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            final day = weekDays[index];
                            final isSelected = _focusedDate.day == day.day &&
                                _focusedDate.month == day.month &&
                                _focusedDate.year == day.year;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _focusedDate = day;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? _kNavy : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
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
                                    const SizedBox(height: 6),
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
