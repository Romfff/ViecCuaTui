import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/notification_model.dart';
import '../../models/interview_model.dart';
import '../../provider/notification_provider.dart';
import '../../provider/interview_provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/custom_button.dart';
import 'interview_schedule_screen.dart';
import 'recruiter_home_screen.dart';

const _kNavy = Color(0xFF0D1B4B);
const _kGreenAccent = Color(0xFF0FB488);
const _kBg = Color(0xFFF8F9FB);
const _kTextSub = Color(0xFF8E8E93);

class CandidateCvDetailScreen extends StatefulWidget {
  final String name;
  final String role;
  final String? cvBody;
  final String? cvFileName;
  final Uint8List? cvBytes;
  final bool fromCandidateList;

  const CandidateCvDetailScreen({
    super.key,
    required this.name,
    required this.role,
    this.cvBody,
    this.cvFileName,
    this.cvBytes,
    this.fromCandidateList = false,
  });

  @override
  State<CandidateCvDetailScreen> createState() => _CandidateCvDetailScreenState();
}

class _CandidateCvDetailScreenState extends State<CandidateCvDetailScreen> {
  String? _selectedDecision;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime; // Thay thế _interviewTimeController
  String? _selectedInterviewType; // 'office' or 'meet'
  final TextEditingController _officeAddressController = TextEditingController();

  String get _decisionKey => widget.cvFileName?.trim().isNotEmpty == true
      ? widget.cvFileName!
      : widget.name;

  @override
  void initState() {
    super.initState();
    _selectedDecision = context.read<NotificationProvider>().getCvDecision(_decisionKey);
  }

  @override
  void dispose() {
    _officeAddressController.dispose();
    super.dispose();
  }

  // Generate time slots from 8:00 to 18:00 with 30-minute intervals
  List<TimeOfDay> _generateTimeSlots() {
    List<TimeOfDay> slots = [];
    for (int hour = 8; hour <= 18; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
      if (hour < 18) {
        slots.add(TimeOfDay(hour: hour, minute: 30));
      }
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final hasBytes = widget.cvBytes != null && widget.cvBytes!.isNotEmpty;
    final hasBody = widget.cvBody != null && widget.cvBody!.trim().isNotEmpty;
    final fileName = widget.cvFileName ?? (hasBytes ? '${widget.name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_')}-CV.bin' : null);

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
        toolbarHeight: 90,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: const Icon(Icons.person, color: _kNavy, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: _kNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.role,
                    style: const TextStyle(
                      color: _kTextSub,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin hồ sơ ứng viên',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12),
                ],
              ),
              child: hasBody
                  ? Text(
                      widget.cvBody!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: _kTextSub,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName ?? 'Không có nội dung CV hiển thị',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _kNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasBytes
                              ? 'CV đã sẵn sàng để tải xuống.'
                              : 'Không có file CV kèm theo.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: _kTextSub,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasBytes || hasBody
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final downloadPath = _getDownloadDirectoryPath();
                        final directory = downloadPath != null
                            ? Directory(downloadPath)
                            : Directory.systemTemp;
                        if (!await directory.exists()) {
                          await directory.create(recursive: true);
                        }

                        final safeName = fileName ?? '${widget.name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_')}-CV.txt';
                        final file = File('${directory.path}${Platform.pathSeparator}$safeName');

                        if (hasBytes) {
                          await file.writeAsBytes(widget.cvBytes!);
                        } else {
                          await file.writeAsString(widget.cvBody ?? '');
                        }

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('CV đã được lưu tại: ${file.path}'),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Tải xuống CV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGreenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng liên hệ ứng viên sẽ được cập nhật sau.'),
                    ),
                  );
                },
                icon: const Icon(Icons.phone_android),
                label: const Text('Liên hệ'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: _kGreenAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  foregroundColor: _kGreenAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedDecision == null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDecision = 'accepted';
                        });
                        context.read<NotificationProvider>().setCvDecision(_decisionKey, 'accepted');
                        context.read<NotificationProvider>().addNotification(
                          NotificationModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'CV của bạn đã được chấp nhận',
                            subtitle: 'Hồ sơ của bạn đã được tuyển dụng. Nhà tuyển dụng sẽ liên hệ bạn sớm.',
                            createdAt: DateTime.now(),
                            recipientRole: 'job_seeker',
                            applicantName: widget.name,
                            applicantRole: widget.role,
                            cvFileName: widget.cvFileName,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã gửi thông báo chấp nhận CV cho ứng viên.'),
                          ),
                        );
                        // Nếu từ CandidateListScreen, quay lại; nếu không, hiển thị form phỏng vấn
                        if (widget.fromCandidateList) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreenAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Chấp nhận'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomOutlinedButton(
                      label: 'Từ Chối',
                      onPressed: () {
                        setState(() {
                          _selectedDecision = 'rejected';
                        });
                        context.read<NotificationProvider>().setCvDecision(_decisionKey, 'rejected');
                        context.read<NotificationProvider>().addNotification(
                          NotificationModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: 'CV của bạn đã bị từ chối',
                            subtitle: 'Hồ sơ của bạn chưa phù hợp lần này. Chúc bạn may mắn lần sau.',
                            createdAt: DateTime.now(),
                            recipientRole: 'job_seeker',
                            applicantName: widget.name,
                            applicantRole: widget.role,
                            cvFileName: widget.cvFileName,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã gửi thông báo từ chối CV cho ứng viên.'),
                          ),
                        );
                      },
                      borderColor: Colors.red,
                      textColor: Colors.red,
                      icon: Icons.close,
                    ),
                  ),
                ],
              ),
            ] else if (_selectedDecision == 'accepted') ...[
              // Interview scheduling section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sắp xếp cuộc phỏng vấn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Calendar
                    const Text(
                      'Chọn ngày phỏng vấn',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 90)),
                        focusedDay: _selectedDate ?? DateTime.now(),
                        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDate = selectedDay;
                          });
                        },
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: _kGreenAccent,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: _kGreenAccent.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Ngày chọn: ${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _kGreenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Interview time - Dropdown Picker
                    const Text(
                      'Giờ phỏng vấn',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: DropdownButton<TimeOfDay>(
                        value: _selectedTime,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        hint: Row(
                          children: [
                            Icon(Icons.access_time, color: _kGreenAccent, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Chọn giờ phỏng vấn',
                              style: TextStyle(
                                fontSize: 14,
                                color: _kTextSub,
                              ),
                            ),
                          ],
                        ),
                        icon: const Icon(Icons.expand_more, color: _kGreenAccent),
                        onChanged: (TimeOfDay? newTime) {
                          if (newTime != null) {
                            setState(() {
                              _selectedTime = newTime;
                            });
                          }
                        },
                        items: _generateTimeSlots().map((TimeOfDay time) {
                          final isSelected = _selectedTime == time;
                          return DropdownMenuItem<TimeOfDay>(
                            value: time,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected ? _kGreenAccent : _kNavy,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.check, color: _kGreenAccent, size: 18),
                                  ]
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Interview type selection
                    const Text(
                      'Hình thức phỏng vấn',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedInterviewType = 'meet';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedInterviewType == 'meet' ? _kGreenAccent : Colors.grey.shade300,
                                  width: _selectedInterviewType == 'meet' ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: _selectedInterviewType == 'meet' ? _kGreenAccent.withOpacity(0.1) : Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.video_call,
                                    color: _selectedInterviewType == 'meet' ? _kGreenAccent : _kTextSub,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Google Meet',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedInterviewType = 'office';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedInterviewType == 'office' ? _kGreenAccent : Colors.grey.shade300,
                                  width: _selectedInterviewType == 'office' ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: _selectedInterviewType == 'office' ? _kGreenAccent.withOpacity(0.1) : Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: _selectedInterviewType == 'office' ? _kGreenAccent : _kTextSub,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tại Văn Phòng',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Office address field
                    if (_selectedInterviewType == 'office') ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Địa chỉ văn phòng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _kNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _officeAddressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Nhập địa chỉ văn phòng',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Submit button
                    Builder(
                      builder: (context) {
                        final isFormValid = _selectedDate != null && 
                                           _selectedTime != null &&
                                           _selectedInterviewType != null &&
                                           (_selectedInterviewType == 'meet' || _officeAddressController.text.isNotEmpty);
                        
                        return CustomButton(
                          label: 'Xác Nhận Phỏng Vấn',
                          isEnabled: isFormValid,
                          onPressed: () async {
                            try {
                              final authProvider = context.read<AuthProvider>();
                              final interviewProvider = context.read<InterviewProvider>();
                              
                              if (authProvider.user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Lỗi: Không tìm thấy người dùng')),
                                );
                                return;
                              }
                              
                              final timeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
                              final interview = InterviewModel(
                                id: '', // Will be set by Firestore
                                recruiterId: authProvider.user!.uid,
                                candidateId: widget.name,
                                candidateName: widget.name,
                                candidateRole: widget.role,
                                interviewTime: '${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year} - $timeString',
                                status: 'pending',
                                createdAt: DateTime.now(),
                                interviewType: _selectedInterviewType!,
                                officeAddress: _selectedInterviewType == 'office' ? _officeAddressController.text : null,
                              );

                              final id = await interviewProvider.createInterview(interview);
                              if (id != null && id.isNotEmpty && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã tạo cuộc phỏng vấn thành công!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                // Navigate to RecruiterHomeScreen with the scheduled date and Interviews tab (index 2)
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => RecruiterHomeScreen(
                                          initialIndex: 2,
                                          initialDate: _selectedDate,
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                });
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi khi tạo cuộc phỏng vấn: ID = $id'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              print('Error creating interview: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi: ${e.toString()}'),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            }
                          },
                          enabledColor: _kGreenAccent,
                          icon: Icons.check,
                        );
                      }
                    ),
                  ],
                ),
              ),
            ] else ...[
              CustomOutlinedButton(
                label: 'Đã từ chối',
                onPressed: null,
                isEnabled: false,
                borderColor: Colors.red,
                textColor: Colors.red,
                icon: Icons.close,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _getDownloadDirectoryPath() {
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null && userProfile.isNotEmpty) {
        return '$userProfile\\Downloads';
      }
    } else if (Platform.isLinux || Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        return '$home/Downloads';
      }
    }
    return null;
  }
}
