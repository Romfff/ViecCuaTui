import 'package:flutter/material.dart';
import '../../models/interview_model.dart';

const _kNavy = Color(0xFF0D1B4B);
const _kGreenAccent = Color(0xFF0FB488);
const _kBg = Color(0xFFF8F9FB);
const _kTextSub = Color(0xFF8E8E93);

class InterviewDetailScreen extends StatelessWidget {
  final InterviewModel interview;

  const InterviewDetailScreen({
    super.key,
    required this.interview,
  });

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
          'Chi Tiết Phỏng Vấn',
          style: TextStyle(
            color: _kNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: interview.status == 'pending'
                    ? Colors.orange.withOpacity(0.2)
                    : interview.status == 'ongoing'
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(interview.status),
                style: TextStyle(
                  color: interview.status == 'pending'
                      ? Colors.orange
                      : interview.status == 'ongoing'
                          ? Colors.blue
                          : Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Card with interview info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                        child: const Icon(Icons.business, color: _kNavy, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nhà Tuyển Dụng',
                              style: TextStyle(
                                color: _kTextSub,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              interview.recruiterId,
                              style: const TextStyle(
                                color: _kNavy,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Interview time
                  Row(
                    children: [
                      Icon(Icons.schedule, color: _kGreenAccent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thời Gian Phỏng Vấn',
                              style: TextStyle(
                                color: _kTextSub,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              interview.interviewTime,
                              style: const TextStyle(
                                color: _kNavy,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Interview type and location
                  Row(
                    children: [
                      Icon(
                        interview.interviewType == 'meet'
                            ? Icons.video_call
                            : Icons.location_on,
                        color: _kGreenAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              interview.interviewType == 'meet'
                                  ? 'Hình Thức: Google Meet'
                                  : 'Hình Thức: Tại Văn Phòng',
                              style: const TextStyle(
                                color: _kTextSub,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (interview.interviewType == 'meet') ...[
                              if (interview.meetLink != null) ...[
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Open Google Meet link
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Tính năng sẽ được cập nhật'),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    interview.meetLink ?? 'Chưa có link',
                                    style: const TextStyle(
                                      color: _kGreenAccent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  'Chưa được cung cấp',
                                  style: TextStyle(
                                    color: _kTextSub,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ] else ...[
                              Text(
                                interview.officeAddress ?? 'Chưa được cung cấp',
                                style: const TextStyle(
                                  color: _kNavy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Vị trí ứng tuyển
                  Row(
                    children: [
                      Icon(Icons.work, color: _kGreenAccent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vị Trí Ứng Tuyển',
                              style: TextStyle(
                                color: _kTextSub,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              interview.candidateRole,
                              style: const TextStyle(
                                color: _kNavy,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (interview.status == 'pending') ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cuộc phỏng vấn sắp diễn ra. Vui lòng chuẩn bị sẵn sàng.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action button
            if (interview.interviewType == 'meet' && interview.meetLink != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đang mở Google Meet...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.video_call),
                  label: const Text('Tham Gia Cuộc Họp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Sắp diễn ra';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'completed':
        return 'Đã hoàn thành';
      default:
        return status;
    }
  }
}
